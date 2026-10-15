import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/utils/money.dart';
import 'package:chimbo/features/catalog/data/models/category.dart';
import 'package:flutter/material.dart';

/// Search box of a listing ("Tafuta kwenye Cosmetics…").
class CatalogSearchField extends StatelessWidget {
  const CatalogSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded),
      ),
    );
  }
}

/// "Zote" + one chip per category, in one compact row that scrolls sideways (as in modern shop
/// apps): one line instead of several, so products start higher on the screen.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Category> categories;

  /// Null = "Zote".
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return _ScrollingRow(
      children: [
        _CompactChip(
          label: context.l10n.chipAll,
          isSelected: selectedId == null,
          onTap: () => onSelected(null),
        ),
        for (final category in categories)
          _CompactChip(
            label: category.name,
            isSelected: category.id == selectedId,
            onTap: () => onSelected(category.id),
          ),
      ],
    );
  }
}

/// The two primary listing controls: filters and sort.
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.activeFilterCount,
    required this.onFilter,
    required this.onSort,
  });

  final int activeFilterCount;
  final VoidCallback onFilter;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      spacing: AppSpacing.sm,
      children: [
        Expanded(
          child: _ListingActionButton(
            label: l10n.filterAction,
            icon: Icons.tune_rounded,
            isActive: activeFilterCount > 0,
            trailing: activeFilterCount > 0
                ? _ActiveFilterCount(count: activeFilterCount)
                : null,
            onPressed: onFilter,
          ),
        ),
        Expanded(
          child: _ListingActionButton(
            label: l10n.sortAction,
            icon: Icons.swap_vert_rounded,
            onPressed: onSort,
          ),
        ),
      ],
    );
  }
}

/// Shows the exact filters currently narrowing the listing; each chip removes one filter.
class ActiveFilterChips extends StatelessWidget {
  const ActiveFilterChips({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.maxMoq,
    required this.onRemovePrice,
    required this.onRemoveMoq,
  });

  final int? minPrice;
  final int? maxPrice;
  final int? maxMoq;
  final VoidCallback onRemovePrice;
  final VoidCallback onRemoveMoq;

  @override
  Widget build(BuildContext context) {
    if (minPrice == null && maxPrice == null && maxMoq == null) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final maxChipWidth = MediaQuery.sizeOf(context).width - AppSpacing.xxl;
    final labels = <({String text, VoidCallback onRemove})>[];
    if (minPrice != null || maxPrice != null) {
      final priceLabel = switch ((minPrice, maxPrice)) {
        (final int minimum, final int maximum) => l10n.activePriceRange(
          Money.format(minimum),
          Money.format(maximum),
        ),
        (final int minimum, null) => l10n.activePriceFrom(
          Money.format(minimum),
        ),
        (null, final int maximum) => l10n.activePriceTo(Money.format(maximum)),
        _ => '',
      };
      labels.add((text: priceLabel, onRemove: onRemovePrice));
    }
    if (maxMoq != null) {
      labels.add((text: l10n.activeMoqLimit(maxMoq!), onRemove: onRemoveMoq));
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          for (final filter in labels)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxChipWidth),
              child: InputChip(
                label: Text(
                  filter.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onDeleted: filter.onRemove,
                deleteIcon: const Icon(Icons.close_rounded),
                visualDensity: VisualDensity.compact,
                backgroundColor: AppColors.primaryLight,
                side: const BorderSide(color: AppColors.primaryLight),
                labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A single line of controls that scrolls sideways when it doesn't fit.
class _ScrollingRow extends StatelessWidget {
  const _ScrollingRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(spacing: AppSpacing.sm, children: children),
    );
  }
}

class _CompactChip extends StatelessWidget {
  const _CompactChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      labelStyle: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary),
    );
  }
}

class _ListingActionButton extends StatelessWidget {
  const _ListingActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.trailing,
    this.isActive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Widget? trailing;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive ? AppColors.primary : AppColors.textPrimary,
        backgroundColor: isActive ? AppColors.primaryLight : AppColors.surface,
        side: BorderSide(
          color: isActive ? AppColors.primary : AppColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        minimumSize: const Size(0, AppSizes.buttonHeight),
        textStyle: Theme.of(context).textTheme.labelMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xs,
        children: [
          Icon(
            icon,
            size: AppSizes.iconMedium,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _ActiveFilterCount extends StatelessWidget {
  const _ActiveFilterCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: AppSizes.iconMedium,
        child: Center(
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
