import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/network/localized_error.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/profile/data/models/experience_model.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/experiences_controller.dart';
import 'package:ytu_assistant/features/profile/presentation/widgets/date_picker_field.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/app_text_field.dart';
import 'package:ytu_assistant/shared/widgets/primary_button.dart';

/// Add or edit a single work-experience entry. Pass an [ExperienceModel] via
/// go_router `extra` to edit; omit it to create.
class ExperienceFormScreen extends ConsumerStatefulWidget {
  const ExperienceFormScreen({super.key, this.experience});

  final ExperienceModel? experience;

  @override
  ConsumerState<ExperienceFormScreen> createState() =>
      _ExperienceFormScreenState();
}

class _ExperienceFormScreenState extends ConsumerState<ExperienceFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _company = TextEditingController();
  final TextEditingController _position = TextEditingController();
  final TextEditingController _description = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _ongoing = false;

  bool get _isEdit => widget.experience != null;

  @override
  void initState() {
    super.initState();
    final ExperienceModel? e = widget.experience;
    if (e != null) {
      _company.text = e.companyName ?? '';
      _position.text = e.position ?? '';
      _description.text = e.description ?? '';
      _startDate = e.startDate;
      _endDate = e.endDate;
      _ongoing = e.isOngoing;
    }
  }

  @override
  void dispose() {
    _company.dispose();
    _position.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _trimOrNull(String v) {
    final String t = v.trim();
    return t.isEmpty ? null : t;
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    final L10n l10n = L10n.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Backend requires at least one of company/position.
    if (_trimOrNull(_company.text) == null &&
        _trimOrNull(_position.text) == null) {
      AppSnackBar.error(context, l10n.valRequired);
      return;
    }
    final Map<String, dynamic> body = <String, dynamic>{
      'company_name': _trimOrNull(_company.text),
      'position': _trimOrNull(_position.text),
      'description': _trimOrNull(_description.text),
      'start_date': _startDate == null ? null : _isoDate(_startDate!),
      'end_date': _ongoing || _endDate == null ? null : _isoDate(_endDate!),
    };

    try {
      final ExperiencesController c =
          ref.read(experiencesControllerProvider.notifier);
      if (_isEdit) {
        await c.edit(widget.experience!.id, body);
      } else {
        await c.create(body);
      }
      if (mounted) {
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, localizedApiError(l10n, error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final bool isLoading = ref.watch(experiencesControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isEdit ? l10n.experienceEditTitle : l10n.experienceAddTitle),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            AppTextField(
              label: l10n.fieldCompany,
              controller: _company,
              prefixIcon: Icons.business_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l10n.fieldPosition,
              controller: _position,
              prefixIcon: Icons.badge_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l10n.fieldDescription,
              controller: _description,
              prefixIcon: Icons.notes_outlined,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            DatePickerField(
              label: l10n.fieldStartDate,
              value: _startDate,
              onChanged: (DateTime? v) => setState(() => _startDate = v),
            ),
            const SizedBox(height: 16),
            DatePickerField(
              label: l10n.fieldEndDate,
              value: _ongoing ? null : _endDate,
              enabled: !_ongoing,
              onChanged: (DateTime? v) => setState(() => _endDate = v),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.stillHere, style: AppTextStyles.bodyLarge),
              value: _ongoing,
              onChanged: (bool v) => setState(() {
                _ongoing = v;
                if (v) {
                  _endDate = null;
                }
              }),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: l10n.actionSave,
              isLoading: isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
