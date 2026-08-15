import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';
import 'app_widgets.dart';

/// Reusable, API-ready filter/sort building blocks used across Partners,
/// Vouchers, and (later) Auctions & Rewards, so every list filters the same
/// way. Mobile-first: horizontal category chips + a "Sortieren" bottom sheet.

/// A live search field (filters as you type). Shows a clear button when filled.
class SearchField extends StatelessWidget {
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  const SearchField({super.key, required this.hint, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(children: [
        Icon(Icons.search_rounded, size: 20, color: AppColors.textLight),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
            onChanged: onChanged,
            style: AppText.body2.copyWith(color: AppColors.textDarker),
            cursorColor: AppColors.brandPrimary,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: tr(hint),
              hintStyle: AppText.body2.copyWith(color: AppColors.textLight),
            ),
          ),
        ),
        if (value.isNotEmpty)
          Tappable(onTap: () => onChanged(''), child: Icon(Icons.close_rounded, size: 18, color: AppColors.textLight)),
      ]),
    );
  }
}

/// Horizontal, scrollable category chips. Pass already-tr'd labels via
/// [labelOf] if the raw values aren't translation keys.
class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;
  final String Function(String)? labelOf;
  const CategoryChips({super.key, required this.categories, required this.selected, required this.onSelect, this.labelOf});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = categories[i];
          final sel = c == selected;
          return Tappable(
            onTap: () => onSelect(c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? AppColors.brandPrimary : AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: sel ? AppColors.brandPrimary : AppColors.borderLightest),
              ),
              child: Text(labelOf?.call(c) ?? tr(c), style: AppText.body3.copyWith(color: sel ? Colors.white : AppColors.textNormal, fontWeight: FontWeight.w700)),
            ),
          );
        },
      ),
    );
  }
}

/// A compact "Sortieren: <label>" button that opens the sort sheet.
class SortButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const SortButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.borderLightest)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.swap_vert_rounded, size: 16, color: AppColors.brandPrimary),
          const SizedBox(width: 6),
          Text(label, style: AppText.body3.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

/// Bottom sheet with a list of sort options (radio). Returns the chosen index,
/// or null if dismissed. [options] are already-tr'd labels.
Future<int?> showSortSheet(BuildContext context, {required List<String> options, required int current}) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderLightest, borderRadius: BorderRadius.circular(999)))),
          const SizedBox(height: 16),
          Text(tr('Sort by'), style: AppText.h4),
          const SizedBox(height: 10),
          for (var i = 0; i < options.length; i++)
            Tappable(
              onTap: () => Navigator.of(ctx).pop(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(children: [
                  Icon(i == current ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, size: 22, color: i == current ? AppColors.brandPrimary : AppColors.textLight),
                  const SizedBox(width: 12),
                  Text(options[i], style: AppText.body1.copyWith(color: AppColors.textDarker, fontWeight: i == current ? FontWeight.w800 : FontWeight.w600, fontSize: 15)),
                ]),
              ),
            ),
        ]),
      ),
    ),
  );
}
