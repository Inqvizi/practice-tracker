import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/models/practice_entry.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_label.dart';
import '../../core/widgets/skill_chip.dart';

/// Screen FR-5 Create/Update: Interactive editor form for practice diary entries.
/// Includes date picking, segment status selection, dynamic skill tag management,
/// and client-side form validation.
class EntryFormScreen extends StatefulWidget {
  const EntryFormScreen({super.key});

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  late final TextEditingController _dateController;
  late final TextEditingController _hoursController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _newSkillController;

  PracticeStatus _status = PracticeStatus.done;
  final List<String> _skills = ['Flutter', 'Dart', 'State Management'];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2025, 5, 26);
    _dateController =
        TextEditingController(text: _formatDate(_selectedDate));
    _hoursController = TextEditingController(text: '3.5');
    _titleController =
        TextEditingController(text: 'UI component design system');
    _descriptionController = TextEditingController(
      text:
          'Constructed reusable layout scaffolding, input primitives, and verified cross-platform responsiveness.',
    );
    _newSkillController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _hoursController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _newSkillController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2026, 12, 31),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _addSkill() {
    final text = _newSkillController.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _newSkillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _saveEntry() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Practice entry saved successfully.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.entryForm,
      breadcrumb: 'Workspace > Practice Entries / Entry details',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= AppSpacing.desktopBreakpoint;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button & Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              'Back to entries',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm + 2,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusXl),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Draft saved',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      const SectionLabel('New practice log'),
                      const SizedBox(height: AppSpacing.xs + 2),
                      const Text(
                        'Add practice entry',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Fields marked with an asterisk are required.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Form Content Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 5, child: _buildLogDetailsColumn()),
                                  const SizedBox(width: AppSpacing.xxl),
                                  Expanded(
                                      flex: 6, child: _buildActivityColumn()),
                                ],
                              )
                            else ...[
                              _buildLogDetailsColumn(),
                              const SizedBox(height: AppSpacing.xl),
                              const Divider(height: 1),
                              const SizedBox(height: AppSpacing.xl),
                              _buildActivityColumn(),
                            ],

                            const SizedBox(height: AppSpacing.xxl),
                            const Divider(height: 1),
                            const SizedBox(height: AppSpacing.lg),

                            // Footer Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                PrimaryButton(
                                  text: 'Save entry',
                                  isFullWidth: false,
                                  icon: const Icon(Icons.check_rounded, size: 18),
                                  onPressed: _saveEntry,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogDetailsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Log details'),
        const SizedBox(height: AppSpacing.lg),

        // Date Field
        GestureDetector(
          onTap: _pickDate,
          child: AbsorbPointer(
            child: AppTextField(
              label: 'Date *',
              hint: 'Select date',
              controller: _dateController,
              prefixIcon: const Icon(
                Icons.calendar_month_outlined,
                size: 19,
                color: AppColors.textSecondary,
              ),
              validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'Date is required' : null,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Hours Spent Field
        AppTextField(
          label: 'Hours spent *',
          hint: 'e.g. 3.5',
          controller: _hoursController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              widthFactor: 0.0,
              child: Text(
                'hours',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Hours are required';
            }
            if (double.tryParse(val) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Status Segment Toggle
        const Text(
          'Status *',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSegmentButton(
                  title: 'In progress',
                  selected: _status == PracticeStatus.inProgress,
                  onTap: () =>
                      setState(() => _status = PracticeStatus.inProgress),
                ),
              ),
              Expanded(
                child: _buildSegmentButton(
                  title: 'Done',
                  selected: _status == PracticeStatus.done,
                  onTap: () => setState(() => _status = PracticeStatus.done),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Activity'),
        const SizedBox(height: AppSpacing.lg),

        // Task Title
        AppTextField(
          label: 'Task title *',
          hint: 'e.g. Implemented authentication flow',
          controller: _titleController,
          validator: (val) =>
              (val == null || val.trim().isEmpty) ? 'Title is required' : null,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Task Description
        AppTextField(
          label: 'Task description *',
          hint: 'Summarize work completed, tools used, and issues resolved…',
          controller: _descriptionController,
          maxLines: 4,
          helperText: '${_descriptionController.text.length} / 500 characters',
          onChanged: (_) => setState(() {}),
          validator: (val) => (val == null || val.trim().isEmpty)
              ? 'Description is required'
              : null,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Skills Gained
        const Text(
          'Skills gained',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        if (_skills.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _skills
                .map((skill) => SkillChip(
                      label: skill,
                      onDeleted: () => _removeSkill(skill),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: _newSkillController,
                  onSubmitted: (_) => _addSkill(),
                  decoration: const InputDecoration(
                    hintText: 'Type a skill and press Enter',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            PrimaryButton(
              text: 'Add',
              isFullWidth: false,
              height: 42,
              icon: const Icon(Icons.add_rounded, size: 16),
              onPressed: _addSkill,
            ),
          ],
        ),
      ],
    );
  }
}
