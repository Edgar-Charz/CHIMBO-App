import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/phone.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_text_field.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/phone_field.dart';
import 'package:chimbo/features/addresses/application/addresses_controller.dart';
import 'package:chimbo/features/addresses/data/models/address.dart';
import 'package:chimbo/features/locations/data/models/district.dart';
import 'package:chimbo/features/locations/data/models/region.dart';
import 'package:chimbo/features/locations/presentation/location_fields.dart';
import 'package:chimbo/features/profile/application/profile_controller.dart';
import 'package:chimbo/features/profile/data/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Anwani Mpya": saves an address and returns it to the screen that opened the form.
/// Name, phone and region start from the profile, so most customers only add the street.
class AddressFormScreen extends ConsumerStatefulWidget {
  const AddressFormScreen({super.key, this.address});

  final Address? address;

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  Region? _region;
  District? _district;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    if (address == null) {
      // Loads the profile if Wasifu hasn't yet; fields fill in when it arrives.
      ref.read(profileControllerProvider.future).then(_prefillFrom).ignore();
    } else {
      _nameController.text = address.recipientName;
      _phoneController.text = TzPhone.groupLocalDigits(
        address.phone.substring(TzPhone.countryCode.length),
      );
      _streetController.text = address.street;
      _landmarkController.text = address.landmark ?? '';
      _region = Region(id: address.regionId, name: address.regionName);
      final districtId = address.districtId;
      final districtName = address.districtName;
      if (districtId != null && districtName != null) {
        _district = District(
          id: districtId,
          regionId: address.regionId,
          name: districtName,
        );
      }
    }
  }

  /// Starts from the customer's own details, without overwriting anything already typed.
  void _prefillFrom(Profile profile) {
    if (!mounted) {
      return;
    }
    setState(() {
      if (_nameController.text.isEmpty) {
        _nameController.text = profile.user.fullName ?? '';
      }
      if (_phoneController.text.isEmpty) {
        _phoneController.text = TzPhone.groupLocalDigits(
          profile.user.phone.substring(TzPhone.countryCode.length),
        );
      }
      final business = profile.business;
      if (_region == null && business != null) {
        _region = Region(id: business.regionId, name: business.regionName);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final controller = ref.read(addressesControllerProvider.notifier);
      final input = AddressInput(
        recipientName: _nameController.text,
        phone: _phoneController.text,
        regionId: _region!.id,
        districtId: _district?.id,
        street: _streetController.text,
        landmark: _landmarkController.text,
      );
      final existingAddress = widget.address;
      final address = existingAddress == null
          ? await controller.add(input)
          : await controller.editAddress(existingAddress.id, input);
      if (mounted) {
        // The screen that opened the form decides what to do with the new address.
        context.pop(address);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppToast.of(context).error(context.l10n.errorMessage(error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.address == null
              ? l10n.addressFormTitle
              : l10n.editAddressFormTitle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.md,
            children: [
              AppTextField(
                label: l10n.recipientNameLabel,
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? l10n.fullNameRequired : null,
              ),
              PhoneField(
                controller: _phoneController,
                validator: (value) => TzPhone.normalize(value ?? '') == null
                    ? l10n.phoneInvalid
                    : null,
              ),
              LocationFields(
                region: _region,
                district: _district,
                onRegionChanged: (region) => setState(() {
                  _region = region;
                  _district = null;
                }),
                onDistrictChanged: (district) =>
                    setState(() => _district = district),
              ),
              AppTextField(
                label: l10n.streetLabel,
                hint: l10n.streetHint,
                controller: _streetController,
                textCapitalization: TextCapitalization.words,
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? l10n.streetRequired : null,
              ),
              AppTextField(
                label: l10n.landmarkLabel,
                hint: l10n.optionalField,
                controller: _landmarkController,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.actionSaveAddress,
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
