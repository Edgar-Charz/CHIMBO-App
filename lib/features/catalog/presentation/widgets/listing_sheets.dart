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

/// Which parts the filter sheet shows: both for "Chuja", one for "Bei" / "MOQ".
enum FilterSection { all, price, moq }

/// "Panga": returns the picked order, or null when dismissed.
Future<ProductSort?> showSortSheet(BuildContext context, ProductSort current) {
  return showModalBottomSheet<ProductSort>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final l10n = context.l10n;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  l10n.sortAction,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final sort in ProductSort.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _SortOption(
                    sort: sort,
                    selected: sort == current,
                    onTap: () => Navigator.of(context).pop(sort),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// "Chuja" / "Bei" / "MOQ": returns the new filters, or null when dismissed.
Future<ListingFilters?> showFilterSheet(
  BuildContext context, {
  required ListingFilters current,
  FilterSection section = FilterSection.all,
}) {
  return showModalBottomSheet<ListingFilters>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _FilterSheet(current: current, section: section),
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
    return Material(
      color: selected ? AppColors.primaryLight : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                _icon,
                size: AppSizes.iconMedium,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(sort.label(context.l10n))),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: AppSizes.iconMedium,
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.current, required this.section});

  final ListingFilters current;
  final FilterSection section;

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

  bool get _showsPrice => widget.section != FilterSection.moq;
  bool get _showsMoq => widget.section != FilterSection.price;

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
      minPrice: _showsPrice ? _parse(_minPrice) : widget.current.minPrice,
      maxPrice: _showsPrice ? _parse(_maxPrice) : widget.current.maxPrice,
      maxMoq: _showsMoq ? _parse(_maxMoq) : widget.current.maxMoq,
    ));
  }

  void _clear() {
    Navigator.of(context).pop((
      minPrice: _showsPrice ? null : widget.current.minPrice,
      maxPrice: _showsPrice ? null : widget.current.maxPrice,
      maxMoq: _showsMoq ? null : widget.current.maxMoq,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.84),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_showsPrice) ...[
                    _SectionTitle(title: l10n.priceFilter),
                    Row(
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
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (_showsMoq) ...[
                    _SectionTitle(title: l10n.moqFilter),
                    _AmountField(
                      controller: _maxMoq,
                      hint: l10n.maxMoqHint,
                      validator: (_) => _validateRange(
                        controller: _maxMoq,
                        isMinimum: false,
                        isMoq: true,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: _apply,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    child: Text(l10n.actionShowResults),
                  ),
                  Align(
                    child: TextButton(
                      onPressed: _clear,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(l10n.actionClearFilters),
                    ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(title, style: Theme.of(context).textTheme.titleSmall),
  );
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
