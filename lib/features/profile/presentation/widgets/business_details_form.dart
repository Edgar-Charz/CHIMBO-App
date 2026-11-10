import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_text_field.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/features/auth/data/models/business_profile_input.dart';
import 'package:chimbo/features/locations/data/models/district.dart';
import 'package:chimbo/features/locations/data/models/region.dart';
import 'package:chimbo/features/locations/presentation/location_fields.dart';
import 'package:chimbo/features/profile/data/models/profile.dart';
import 'package:flutter/material.dart';
/// Customer name, optional email and shop details for registration and profile editing.
/// Shared by registration step 3 and "Hariri Wasifu", so both check the same rules.
class BusinessDetailsForm extends StatefulWidget {
  const BusinessDetailsForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.initial,
  });

  final String submitLabel;

  /// Saves the details; an `ApiException` it throws is shown to the customer.
  final Future<void> Function(BusinessProfileInput input) onSubmit;

  /// Pre-fills the fields when editing.
  final Profile? initial;

  @override
  State<BusinessDetailsForm> createState() => _BusinessDetailsFormState();
}

class _BusinessDetailsFormState extends State<BusinessDetailsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _emailController;
  Region? _region;
  District? _district;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final business = widget.initial?.business;
    _fullNameController = TextEditingController(
      text: widget.initial?.user.fullName,
    );
    _businessNameController = TextEditingController(
      text: business?.businessName,
    );
    _emailController = TextEditingController(text: widget.initial?.user.email);
    if (business != null) {
      _region = Region(id: business.regionId, name: business.regionName);
      final districtId = business.districtId;
      final districtName = business.districtName;
      if (districtId != null && districtName != null) {
        _district = District(
          id: districtId,
          regionId: business.regionId,
          name: districtName,
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final businessName = _businessNameController.text.trim();
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(
        BusinessProfileInput(
          fullName: _fullNameController.text.trim(),
          businessName: businessName.isEmpty ? null : businessName,
          regionId: _region!.id,
          districtId: _district?.id,
          userEmail: _emailController.text.trim(),
        ),
      );
    } catch (error) {
      if (mounted) {
        AppToast.of(context).error(context.l10n.errorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: l10n.fullNameLabel,
            controller: _fullNameController,
            minHeight: AppSizes.buttonHeight,
            enabled: !_isSubmitting,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            validator: (value) =>
                (value ?? '').trim().isEmpty ? l10n.fullNameRequired : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: l10n.emailLabel,
            hint: l10n.optionalField,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            enabled: !_isSubmitting,
            validator: (value) {
              final email = (value ?? '').trim();
              if (email.isNotEmpty &&
                  !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return l10n.emailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: l10n.businessNameLabel,
            hint: l10n.optionalField,
            controller: _businessNameController,
            minHeight: AppSizes.buttonHeight,
            enabled: !_isSubmitting,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppSpacing.md),
          LocationFields(
            region: _region,
            district: _district,
            enabled: !_isSubmitting,
            onRegionChanged: (region) => setState(() {
              _region = region;
              _district = null;
            }),
            onDistrictChanged: (district) =>
                setState(() => _district = district),
            fieldMinHeight: AppSizes.buttonHeight,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: widget.submitLabel,
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
