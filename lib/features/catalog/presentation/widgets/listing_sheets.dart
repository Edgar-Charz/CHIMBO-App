import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/catalog/presentation/widgets/catalog_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Numeric filters returned by a filter sheet.
typedef ListingFilters = ({int? minPrice, int? maxPrice, int? maxMoq});

/// "Panga": returns the picked order, or null when dismissed.
Future<ProductSort?> showSortSheet(BuildContext context, ProductSort current) {
  return showModalBottomSheet<ProductSort>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.large),
      ),
    ),
    builder: (context) => _SortSheet(current: current),
  );
}

/// "Chuja": returns the new price and MOQ filters, or null when dismissed.
Future<ListingFilters?> showFilterSheet(
  BuildContext context, {
  required ListingFilters current,
}) {
  return showModalBottomSheet<ListingFilters>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.large),
      ),
    ),
    builder: (context) => _FilterSheet(current: current),
  );
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.sort,
    required this.selected,
    required this.onTap,
  });

  final ProductSort sort;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon => switch (sort) {
    ProductSort.popular => Icons.local_fire_department_outlined,
    ProductSort.newest => Icons.new_releases_outlined,
    ProductSort.priceLowToHigh => Icons.arrow_downward_rounded,
    ProductSort.priceHighToLow => Icons.arrow_upward_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? AppColors.primary : AppColors.textSecondary;
    return Material(
      color: selected ? AppColors.primaryLight : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected ? AppColors.surface : AppColors.neutralLight,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(_icon, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  sort.label(context.l10n),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: selected
                      ? null
                      : const Border.fromBorderSide(
                          BorderSide(color: AppColors.border, width: 1.5),
                        ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: AppSizes.iconSmall,
                        color: AppColors.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current});

  final ProductSort current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: const Icon(
                        Icons.swap_vert_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.sortSheetTitle,
                            style: textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            l10n.sortSheetSubtitle,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: l10n.actionCancel,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final sort in ProductSort.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _SortOption(
                          sort: sort,
                          selected: sort == current,
                          onTap: () => Navigator.of(context).pop(sort),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.current});

  final ListingFilters current;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _minPrice = TextEditingController(
    text: _formatAmount(widget.current.minPrice),
  );
  late final TextEditingController _maxPrice = TextEditingController(
    text: _formatAmount(widget.current.maxPrice),
  );
  late final TextEditingController _maxMoq = TextEditingController(
    text: _formatAmount(widget.current.maxMoq),
  );

  static final NumberFormat _amountFormat = NumberFormat('#,##0', 'en_US');

  static String _formatAmount(int? value) =>
      value == null ? '' : _amountFormat.format(value);

  @override
  void dispose() {
    _minPrice.dispose();
    _maxPrice.dispose();
    _maxMoq.dispose();
    super.dispose();
  }

  int? _parse(TextEditingController controller) {
    final value = controller.text.replaceAll(',', '').trim();
    return value.isEmpty ? null : int.tryParse(value);
  }

  String? _validateRange({
    required TextEditingController controller,
    TextEditingController? other,
    required bool isMinimum,
    required bool isMoq,
  }) {
    final value = _parse(controller);
    if (controller.text.trim().isEmpty) return null;
    final l10n = context.l10n;
    if (value == null || (isMoq && value < 1)) {
      return l10n.invalidFilterAmount;
    }
    final otherValue = other == null ? null : _parse(other);
    if (otherValue != null &&
        (isMinimum ? value > otherValue : value < otherValue)) {
      return l10n.invalidFilterRange;
    }
    return null;
  }

  void _apply() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop((
      minPrice: _parse(_minPrice),
      maxPrice: _parse(_maxPrice),
      maxMoq: _parse(_maxMoq),
    ));
  }

  void _clear() {
    Navigator.of(context).pop((minPrice: null, maxPrice: null, maxMoq: null));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.88),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.filterSheetTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.filterSheetSubtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: l10n.actionCancel,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FilterSectionCard(
                        icon: Icons.payments_outlined,
                        title: l10n.priceFilter,
                        description: l10n.priceFilterDescription,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _AmountField(
                                controller: _minPrice,
                                hint: l10n.minPriceHint,
                                prefix: 'TZS ',
                                validator: (_) => _validateRange(
                                  controller: _minPrice,
                                  other: _maxPrice,
                                  isMinimum: true,
                                  isMoq: false,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.md,
                              ),
                              child: Text('–'),
                            ),
                            Expanded(
                              child: _AmountField(
                                controller: _maxPrice,
                                hint: l10n.maxPriceHint,
                                prefix: 'TZS ',
                                validator: (_) => _validateRange(
                                  controller: _maxPrice,
                                  other: _minPrice,
                                  isMinimum: false,
                                  isMoq: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FilterSectionCard(
                        icon: Icons.inventory_2_outlined,
                        title: l10n.moqFilter,
                        description: l10n.moqFilterDescription,
                        child: _AmountField(
                          controller: _maxMoq,
                          hint: l10n.maxMoqHint,
                          validator: (_) => _validateRange(
                            controller: _maxMoq,
                            isMinimum: false,
                            isMoq: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: _clear,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: Text(l10n.actionClearFilters),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _apply,
                          icon: const Icon(Icons.check_rounded),
                          label: Text(l10n.actionShowResults),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSectionCard extends StatelessWidget {
  const _FilterSectionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.hint,
    this.prefix,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: const [_ThousandsSeparatorInputFormatter()],
      validator: validator,
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        prefixText: prefix,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const _ThousandsSeparatorInputFormatter();

  static final NumberFormat _formatter = NumberFormat('#,##0', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final selectionOffset = newValue.selection.extentOffset
        .clamp(0, newValue.text.length)
        .toInt();
    final digitsBeforeCursor = newValue.text
        .substring(0, selectionOffset)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    if (digits.length > 12) return oldValue;

    final formatted = _formatter.format(int.parse(digits));
    var formattedCursor = 0;
    var seenDigits = 0;
    while (formattedCursor < formatted.length &&
        seenDigits < digitsBeforeCursor) {
      if (_isDigit(formatted.codeUnitAt(formattedCursor))) seenDigits++;
      formattedCursor++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formattedCursor),
    );
  }

  static bool _isDigit(int codeUnit) => codeUnit >= 48 && codeUnit <= 57;
}
