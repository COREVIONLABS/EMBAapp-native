import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';

/// A grouped card of rows (settings sections).
class SettingsGroup extends StatelessWidget {
  final List<Widget> rows;
  const SettingsGroup(this.rows, {super.key});
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1) Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.borderLightest),
          ],
        ],
      ),
    );
  }
}

class ToggleRow extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool initial;
  const ToggleRow(this.title, {super.key, this.subtitle, this.initial = false});
  @override
  State<ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<ToggleRow> {
  late bool _on = widget.initial;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15)),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(widget.subtitle!, style: AppText.body3Regular),
                ],
              ],
            ),
          ),
          Switch(
            value: _on,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.brandPrimary,
            onChanged: (v) => setState(() => _on = v),
          ),
        ],
      ),
    );
  }
}

class SelectRow extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  const SelectRow(this.title, {super.key, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(title, style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15))),
            if (selected) const Icon(Icons.check_rounded, color: AppColors.brandPrimary),
          ],
        ),
      ),
    );
  }
}
