import 'dart:math' as math;

import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/chimbo_loader.dart';
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
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
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
                    : const Icon(Icons.search_rounded),
              ),
              child: Text(
                field.value == null ? '' : itemLabel(field.value as T),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (options.isLoading) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Row(
                children: [
                  const ChimboLoader(compact: true, showMessage: false),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    context.l10n.locationLoading,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ],
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
    backgroundColor: AppColors.primaryLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.large),
      ),
    ),
    clipBehavior: Clip.antiAlias,
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
    final visibleRows = math.min(widget.options.length, 6);
    final listHeight = widget.options.isEmpty
        ? 112.0
        : visibleRows * 44.0 +
              math.max(0, visibleRows - 1) * AppSpacing.sm +
              AppSpacing.xs +
              AppSpacing.md;
    final sheetHeight = math.min(availableHeight * 0.76, 130 + listHeight);
    final query = _controller.text.trim().toLowerCase();
    final filtered = widget.options
        .where(
          (option) => widget.itemLabel(option).toLowerCase().contains(query),
        )
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: sheetHeight,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surface, AppColors.primaryLight],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primaryLight, AppColors.surface],
                        ),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                        size: AppSizes.iconMedium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_searching_rounded,
                                color: AppColors.textSecondary,
                                size: AppSizes.iconLarge,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                context.l10n.locationNoResults,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.xs,
                          AppSpacing.md,
                          AppSpacing.md,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final option = filtered[index];
                          return _LocationOptionCard(
                            label: widget.itemLabel(option),
                            selected: option == widget.selected,
                            onTap: () => Navigator.of(context).pop(option),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationOptionCard extends StatefulWidget {
  const _LocationOptionCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_LocationOptionCard> createState() => _LocationOptionCardState();
}

class _LocationOptionCardState extends State<_LocationOptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.medium);
    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1,
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: widget.selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (highlighted) {
            setState(() => _isPressed = highlighted);
          },
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: widget.selected
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [AppColors.primaryLight, AppColors.surface],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.surface, AppColors.background],
                    ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: widget.selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: widget.selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (widget.selected)
                    const Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: AppSizes.iconMedium,
                    )
                  else
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: AppSizes.iconMedium,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
