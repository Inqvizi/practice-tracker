import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_label.dart';

/// Screen FR-1: Student registration screen.
/// Features a two-panel adaptive layout (hero banner on desktop, form on right),
/// with decorative shapes, input validation, and route switching.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: 'Oleksandr');
  final _lastNameController = TextEditingController(text: 'Firko');
  final _emailController =
      TextEditingController(text: 'oleksandr.firko@university.edu');
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.dashboard,
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= AppSpacing.desktopBreakpoint;

          return Row(
            children: [
              // Left Hero Banner (Desktop only)
              if (isDesktop)
                Expanded(
                  flex: 45,
                  child: _HeroBannerPanel(),
                ),

              // Right Form Container
              Expanded(
                flex: isDesktop ? 55 : 100,
                child: Container(
                  color: AppColors.surfaceMuted,
                  height: double.infinity,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.xxl,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSpacing.cardMaxWidth,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Small logo on mobile when hero is hidden
                              if (!isDesktop) ...[
                                const Center(
                                  child: AppLogo(iconSize: 38, fontSize: 20),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                              ],

                              const SectionLabel('Create account'),
                              const SizedBox(height: AppSpacing.xs + 2),
                              const Text(
                                'Start tracking your practice',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Set up your student account in just a minute.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Name Row
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      label: 'First name',
                                      hint: 'Oleksandr',
                                      controller: _firstNameController,
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'Last name',
                                      hint: 'Firko',
                                      controller: _lastNameController,
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Email
                              AppTextField(
                                label: 'Email address',
                                hint: 'oleksandr.firko@university.edu',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(
                                  Icons.mail_outline_rounded,
                                  size: 19,
                                  color: AppColors.textSecondary,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!val.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Password
                              AppTextField(
                                label: 'Password',
                                hint: 'At least 8 characters',
                                controller: _passwordController,
                                isPassword: true,
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 19,
                                  color: AppColors.textSecondary,
                                ),
                                validator: (val) {
                                  if (val == null || val.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Sign Up Button
                              PrimaryButton(
                                text: 'Sign up',
                                isLoading: _isLoading,
                                onPressed: _handleRegister,
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Back to Login Link
                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Text(
                                      'Already have an account? ',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushReplacementNamed(
                                          AppRoutes.login,
                                        );
                                      },
                                      child: const Text(
                                        'Log in',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Left Hero Banner panel shown on wider viewports.
class _HeroBannerPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primaryLight,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative background geometric shapes
          Positioned(
            right: -60,
            bottom: -50,
            child: Transform.rotate(
              angle: 18 * math.pi / 180,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(48),
                ),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: 80,
            child: Transform.rotate(
              angle: 32 * math.pi / 180,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),

          // Main Hero Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo with inverted badge
                const AppLogo(inverted: true, iconSize: 42, fontSize: 22),
                const Spacer(),

                // Eyebrow
                const SectionLabel(
                  'Build your professional story',
                  color: AppColors.sidebarActive,
                  fontSize: 12,
                ),
                const SizedBox(height: AppSpacing.md),

                // Large Main Title
                const Text(
                  'Every hour of practice moves you forward.',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Subtitle
                const Text(
                  'Capture your work, reflect on your growth, and create a clear record of your internship journey.',
                  style: TextStyle(
                    color: Color(0xFFD6E3ED),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Divider
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Feature Highlights
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Track meaningful progress',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Hours, skills, tasks, and milestones in one place.',
                            style: TextStyle(
                              color: Color(0xFFC7D7E3),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
