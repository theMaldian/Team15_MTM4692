import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';

/// A read-only field that opens a date picker on tap and reports the chosen
/// date (or null when cleared).
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(now.year - 60),
      lastDate: DateTime(now.year + 15),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(14);
    final String text = value == null
        ? ''
        : MaterialLocalizations.of(context).formatMediumDate(value!);

    return InkWell(
      onTap: enabled ? () => _pick(context) : null,
      borderRadius: radius,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.event_outlined,
              size: 20,
              color: enabled ? AppColors.primaryLight : AppColors.textSecondary),
          suffixIcon: (value == null || !enabled)
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onChanged(null),
                ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: enabled ? 0.6 : 0.35),
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
