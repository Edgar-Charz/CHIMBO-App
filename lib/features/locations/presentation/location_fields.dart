import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/features/locations/application/location_providers.dart';
import 'package:chimbo/features/locations/data/models/district.dart';
import 'package:chimbo/features/locations/data/models/region.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Searchable Mkoa (required) and Wilaya (optional) fields. Changing region clears the district.
class LocationFields extends ConsumerWidget {
  const LocationFields({
    super.key,
    required this.region,
    required this.district,
    required this.onRegionChanged,
    required this.onDistrictChanged,
    this.enabled = true,
    this.fieldMinHeight,
  });

  final Region? region;
  final District? district;
  final ValueChanged<Region?> onRegionChanged;
  final ValueChanged<District?> onDistrictChanged;
  final bool enabled;
  final double? fieldMinHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selectedRegion = region;
    final regions = ref.watch(regionsProvider);
    final districts = selectedRegion == null
        ? const AsyncValue<List<District>>.data([])
        : ref.watch(districtsProvider(selectedRegion.id));

    return Column(
      children: [
        _AsyncSearchPicker<Region>(
          options: regions,
          value: region,
          label: l10n.regionLabel,
          hint: l10n.regionHint,
          itemLabel: (region) => region.name,
          validator: (value) => value == null ? l10n.regionRequired : null,
          onChanged: enabled ? onRegionChanged : null,
          onRetry: enabled ? () => ref.invalidate(regionsProvider) : null,
          minHeight: fieldMinHeight,
        ),
        const SizedBox(height: AppSpacing.md),
        _AsyncSearchPicker<District>(
          // New key per region so the field forgets the old region's district.
          key: ValueKey(selectedRegion?.id),
          options: districts,
          value: district,
          label: l10n.districtLabel,
          hint: l10n.optionalField,
          itemLabel: (district) => district.name,
          onChanged: enabled && selectedRegion != null
              ? onDistrictChanged
              : null,
          onRetry: !enabled || selectedRegion == null
              ? null
              : () => ref.invalidate(districtsProvider(selectedRegion.id)),
          minHeight: fieldMinHeight,
        ),
      ],
    );
  }
}

/// A searchable picker whose options load from the server.
class _AsyncSearchPicker<T> extends StatelessWidget {
  const _AsyncSearchPicker({
    super.key,
    required this.options,
    required this.value,
    required this.label,
    required this.hint,
    required this.itemLabel,
    required this.onChanged,
    required this.onRetry,
    this.validator,
    this.minHeight,
  });

  final AsyncValue<List<T>> options;
  final T? value;
  final String label;
  final String hint;
  final String Function(T option) itemLabel;
  final ValueChanged<T?>? onChanged;
  final VoidCallback? onRetry;
  final FormFieldValidator<T>? validator;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    final items = options.value ?? const [];
    final isEnabled = !options.isLoading && onChanged != null;
    return FormField<T>(
      key: ValueKey(value),
      initialValue: value,
      validator: validator,
      builder: (field) => InkWell(
        onTap: options.hasError && retry != null
            ? retry
            : isEnabled
            ? () async {
                final selected = await _showSearchPicker<T>(
                  context: context,
                  title: label,
                  options: items,
                  selected: field.value,
                  itemLabel: itemLabel,
                );
                if (selected != null) {
                  field.didChange(selected);
                  onChanged?.call(selected);
                }
              }
            : null,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: InputDecorator(
          isEmpty: field.value == null,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            constraints: minHeight == null
                ? null
                : BoxConstraints(minHeight: minHeight!),
            errorText: options.hasError
                ? context.l10n.locationsLoadFailed
                : field.errorText,
            suffixIcon: options.hasError
                ? const Icon(Icons.refresh_rounded)
                : options.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      width: AppSizes.iconSmall,
                      height: AppSizes.iconSmall,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search_rounded),
          ),
          child: Text(
            field.value == null ? '' : itemLabel(field.value as T),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

Future<T?> _showSearchPicker<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required T? selected,
  required String Function(T) itemLabel,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _SearchPickerSheet<T>(
      title: title,
      options: options,
      selected: selected,
      itemLabel: itemLabel,
    ),
  );
}

class _SearchPickerSheet<T> extends StatefulWidget {
  const _SearchPickerSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.itemLabel,
  });

  final String title;
  final List<T> options;
  final T? selected;
  final String Function(T) itemLabel;

  @override
  State<_SearchPickerSheet<T>> createState() => _SearchPickerSheetState<T>();
}

class _SearchPickerSheetState<T> extends State<_SearchPickerSheet<T>> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final availableHeight = media.size.height - media.viewInsets.bottom;
    final query = _controller.text.trim().toLowerCase();
    final filtered = widget.options
        .where(
          (option) => widget.itemLabel(option).toLowerCase().contains(query),
        )
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: availableHeight * 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: AppColors.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: context.l10n.locationSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .deleteButtonTooltip,
                          onPressed: () {
                            _controller.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(context.l10n.locationNoResults))
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final option = filtered[index];
                        final isSelected = option == widget.selected;
                        return ListTile(
                          title: Text(widget.itemLabel(option)),
                          selected: isSelected,
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
