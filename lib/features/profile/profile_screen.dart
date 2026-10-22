import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../core/constants/app_routes.dart';
import '../../core/errors/auth_failure.dart';
import '../../core/services/avatar_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/validators/validators.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_label.dart';
import '../../core/widgets/user_avatar.dart';
import '../auth/data/auth_scope.dart';

/// Screen FR-3 / FR-6: Student profile overview and security settings.
/// Supports choosing an avatar file from computer (PNG/JPG), preset Dicebear avatars,
/// read-only institutional email, personal details modification,
/// password change with reauthentication, and Sentry diagnostics.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _personalFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _groupSpecialtyController;
  late final TextEditingController _emailController;

  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  User? _currentUser;
  Uint8List? _localImageBytes;
  bool _isSavingPersonal = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;

    final names = (_currentUser?.displayName ?? 'Oleksandr Firko').split(' ');
    final firstName = names.isNotEmpty ? names.first : 'Oleksandr';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : 'Firko';

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _groupSpecialtyController = TextEditingController(text: 'PZ-32 · Software Engineering');
    _emailController = TextEditingController(text: _currentUser?.email ?? 'oleksandr.firko@university.edu');

    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _loadLocalAvatar();
  }

  Future<void> _loadLocalAvatar() async {
    final uid = _currentUser?.uid;
    if (uid != null) {
      final bytes = await AvatarService.getLocalAvatar(uid);
      if (mounted && bytes != null) {
        setState(() {
          _localImageBytes = bytes;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _groupSpecialtyController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _refreshUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
      if (_currentUser != null) {
        _emailController.text = _currentUser!.email ?? '';
      }
    });
  }

  Future<void> _updateAvatar(String selectedUrl) async {
    try {
      final authRepo = AuthScope.of(context);
      await authRepo.updatePhotoUrl(selectedUrl);
      final uid = _currentUser?.uid;
      if (uid != null) {
        await AvatarService.clearLocalAvatar(uid);
      }
      setState(() {
        _localImageBytes = null;
      });
      await FirebaseAnalytics.instance.logEvent(name: 'profile_photo_changed');

      if (!mounted) return;
      _refreshUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фото профілю успішно оновлено.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не вдалося оновити фото.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickImageFromComputer(BuildContext dialogContext) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final uid = _currentUser?.uid;
        if (uid != null) {
          await AvatarService.saveLocalAvatar(uid, bytes);
        }
        setState(() {
          _localImageBytes = bytes;
        });

        await FirebaseAnalytics.instance.logEvent(name: 'profile_photo_changed');

        if (dialogContext.mounted) {
          Navigator.of(dialogContext).pop();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Фото з компʼютера успішно завантажено!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка завантаження файлу: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showAvatarPicker(BuildContext context) async {
    final customUrlController = TextEditingController();
    final pickerFormKey = GlobalKey<FormState>();
    String? selectedUrl = _currentUser?.photoURL;

    final presets = const [
      'https://api.dicebear.com/7.x/bottts/png?seed=Felix',
      'https://api.dicebear.com/7.x/bottts/png?seed=Aneka',
      'https://api.dicebear.com/7.x/bottts/png?seed=Zack',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Aneka',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Zack',
    ];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              title: const Text(
                'Change profile photo',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Form(
                    key: pickerFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Option 1: File from computer
                        const Text(
                          '1. Upload an image file from your computer:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImageFromComputer(dialogContext),
                            icon: const Icon(Icons.upload_file_rounded, size: 20),
                            label: const Text('Choose file from computer (PNG / JPG)'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.primary, width: 1.5),
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),
                        const Divider(),
                        const SizedBox(height: AppSpacing.md),

                        // Option 2: Presets
                        const Text(
                          '2. Or choose one of the preset avatars:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: presets.map((url) {
                            final isSelected = selectedUrl == url;
                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedUrl = url;
                                  customUrlController.clear();
                                });
                              },
                              borderRadius: BorderRadius.circular(40),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColors.background,
                                  backgroundImage: NetworkImage(url),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: AppSpacing.lg),
                        const Divider(),
                        const SizedBox(height: AppSpacing.md),

                        // Option 3: Custom URL
                        const Text(
                          '3. Or enter a direct HTTPS image URL:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs + 2),
                        TextFormField(
                          controller: customUrlController,
                          decoration: const InputDecoration(
                            hintText: 'https://example.com/avatar.png',
                            prefixIcon: Icon(Icons.link_rounded, size: 20),
                          ),
                          validator: (value) {
                            if (selectedUrl != null &&
                                selectedUrl!.isNotEmpty &&
                                (value == null || value.trim().isEmpty)) {
                              return null;
                            }
                            if (value == null || value.trim().isEmpty) {
                              return 'Select an avatar or enter a URL.';
                            }
                            if (!value.trim().startsWith('https://')) {
                              return 'URL must start with https://';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            if (val.trim().isNotEmpty) {
                              setDialogState(() {
                                selectedUrl = val.trim();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (customUrlController.text.trim().isNotEmpty) {
                      if (!(pickerFormKey.currentState?.validate() ?? false)) {
                        return;
                      }
                      selectedUrl = customUrlController.text.trim();
                    }
                    if (selectedUrl == null || selectedUrl!.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select an avatar, upload a file, or enter a URL.'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                      return;
                    }

                    final urlToSave = selectedUrl!;
                    Navigator.of(dialogContext).pop();
                    _updateAvatar(urlToSave);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save preset / URL'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _onSavePersonalDetails() async {
    if (!(_personalFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isSavingPersonal = true);

    try {
      final authRepo = AuthScope.of(context);
      await authRepo.updateDisplayName(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      await FirebaseAnalytics.instance.logEvent(name: 'profile_updated');

      _refreshUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дані профілю успішно оновлено.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не вдалося зберегти зміни.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingPersonal = false);
      }
    }
  }

  Future<void> _onChangePassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

    setState(() => _isChangingPassword = true);

    try {
      final authRepo = AuthScope.of(context);
      await authRepo.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      await FirebaseAnalytics.instance.logEvent(name: 'password_changed');

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пароль успішно змінено.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Помилка зміни пароля. Спробуйте пізніше.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isChangingPassword = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.profile,
      breadcrumb: 'Workspace > Profile',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= AppSpacing.desktopBreakpoint;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page Header
                    const SectionLabel('Account', color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.xs + 2),
                    const Text(
                      'Profile & settings',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage your student personal information, profile photo, and password security.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Two-Column Layout
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: _buildOverviewCard()),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(flex: 6, child: _buildSecurityCard()),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildOverviewCard(),
                          const SizedBox(height: AppSpacing.xl),
                          _buildSecurityCard(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard() {
    final displayName = _currentUser?.displayName ??
        '${_firstNameController.text} ${_lastNameController.text}'.trim();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Profile overview',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your student profile & public avatar',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Entire Avatar with Hover and Click Action
          Tooltip(
            message: 'Click to change profile photo',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showAvatarPicker(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: ClipOval(
                        child: UserAvatar(
                          user: _currentUser,
                          radius: 48,
                          localImageBytes: _localImageBytes,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: AppColors.primary,
                        shape: const CircleBorder(),
                        elevation: 3,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.textLight,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Direct Change Photo button
          TextButton.icon(
            onPressed: () => _showAvatarPicker(context),
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
            label: const Text('Change photo'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Full Name & Program Chip
          Text(
            displayName.isEmpty ? 'Student' : displayName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Text(
              _groupSpecialtyController.text,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.lg),

          // Institutional Email (Read-Only)
          AppTextField(
            label: 'Institutional Email',
            hint: _emailController.text,
            controller: _emailController,
            readOnly: true,
            prefixIcon: const Icon(
              Icons.mail_outline_rounded,
              size: 19,
              color: AppColors.textSecondary,
            ),
            suffixIcon: const Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            helperText:
                'Email cannot be changed here. It is institutional and managed by the university.',
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account & security',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Update your personal information and password',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Section 1: Personal Information
          Form(
            key: _personalFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Personal information'),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'First name',
                        hint: 'Oleksandr',
                        controller: _firstNameController,
                        enabled: !_isSavingPersonal,
                        validator: (val) => Validators.requiredField(
                          val,
                          fieldName: 'First name',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        label: 'Last name',
                        hint: 'Firko',
                        controller: _lastNameController,
                        enabled: !_isSavingPersonal,
                        validator: (val) => Validators.requiredField(
                          val,
                          fieldName: 'Last name',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Group / Specialty',
                  hint: 'PZ-32 · Software Engineering',
                  controller: _groupSpecialtyController,
                  enabled: !_isSavingPersonal,
                ),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: PrimaryButton(
                    text: 'Save personal details',
                    isFullWidth: false,
                    isLoading: _isSavingPersonal,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    onPressed: _isSavingPersonal ? null : _onSavePersonalDetails,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),

          // Section 2: Change Password
          Form(
            key: _passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Change password'),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Current password',
                  hint: '••••••••',
                  controller: _currentPasswordController,
                  isPassword: true,
                  enabled: !_isChangingPassword,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Введіть поточний пароль.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'New password',
                        hint: 'At least 8 characters',
                        controller: _newPasswordController,
                        isPassword: true,
                        enabled: !_isChangingPassword,
                        validator: Validators.password,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        label: 'Confirm new password',
                        hint: 'Repeat password',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        enabled: !_isChangingPassword,
                        validator: (val) => Validators.confirmPassword(
                          val,
                          _newPasswordController.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: PrimaryButton(
                    text: 'Update password',
                    isFullWidth: false,
                    isLoading: _isChangingPassword,
                    icon: const Icon(Icons.lock_reset_rounded, size: 18),
                    onPressed: _isChangingPassword ? null : _onChangePassword,
                  ),
                ),
              ],
            ),
          ),

          // Section 3: Sentry Diagnostics (Visible in Debug Mode)
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.xl),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.lg),
            const SectionLabel('Diagnostics & Sentry', color: AppColors.danger),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Test real-time error tracking and telemetry integration with Sentry on Flutter Web.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  await Sentry.captureException(
                    Exception('Тестова помилка ЛР4 (Sentry Web Integration)'),
                    stackTrace: StackTrace.current,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Тестову помилку успішно надіслано в Sentry!'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Помилка відправки в Sentry: $e'),
                      backgroundColor: AppColors.danger,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(
                Icons.bug_report_rounded,
                color: AppColors.danger,
                size: 18,
              ),
              label: const Text(
                'Send test error (Sentry)',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
