import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
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

/// Chuja · Panga · Bei ▾ · MOQ ▾ as small pills; a pill looks active while its filter is on.
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.hasFilters,
    required this.hasPriceFilter,
    required this.hasMoqFilter,
    required this.onFilter,
    required this.onSort,
    required this.onPrice,
    required this.onMoq,
  });

  final bool hasFilters;
  final bool hasPriceFilter;
  final bool hasMoqFilter;
  final VoidCallback onFilter;
  final VoidCallback onSort;
  final VoidCallback onPrice;
  final VoidCallback onMoq;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = [
      _FilterPill(
        label: l10n.filterAction,
        icon: Icons.tune_rounded,
        isActive: hasFilters,
        onPressed: onFilter,
      ),
      _FilterPill(
        label: l10n.sortAction,
        icon: Icons.swap_vert_rounded,
        onPressed: onSort,
      ),
      _FilterPill(
        label: l10n.priceFilter,
        trailingIcon: Icons.expand_more_rounded,
        isActive: hasPriceFilter,
        onPressed: onPrice,
      ),
      _FilterPill(
        label: l10n.moqFilter,
        trailingIcon: Icons.expand_more_rounded,
        isActive: hasMoqFilter,
        onPressed: onMoq,
      ),
    ];
    return Row(
      spacing: AppSpacing.sm,
      children: [for (final filter in filters) Expanded(child: filter)],
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

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isActive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final leading = icon;
    final trailing = trailingIcon;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive ? AppColors.primary : AppColors.textPrimary,
        backgroundColor: isActive ? AppColors.primaryLight : AppColors.surface,
        side: BorderSide(
          color: isActive ? AppColors.primary : AppColors.border,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: Theme.of(context).textTheme.labelMedium,
      ),
      // Pills share the row equally; on narrow phones or with large text the label shortens
      // with "…" instead of overflowing.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xs,
        children: [
          if (leading != null) Icon(leading, size: AppSizes.iconSmall),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (trailing != null) Icon(trailing, size: AppSizes.iconSmall),
        ],
      ),
    );
  }
}
