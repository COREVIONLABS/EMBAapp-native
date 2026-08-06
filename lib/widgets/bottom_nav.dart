import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';
import 'app_widgets.dart';

class NavDest {
  final String? icon;
  final IconData? iconData;
  final String label;
  const NavDest(this.icon, this.label, {this.iconData});
}

const kNavDestinations = [
  NavDest('nav_home', 'Home'),
  NavDest(null, 'Redeem', iconData: Icons.card_giftcard_rounded),
  NavDest(null, 'Prizes', iconData: Icons.emoji_events_rounded),
  NavDest(null, 'Fan+', iconData: Icons.workspace_premium_outlined),
  NavDest('nav_profile', 'Profile'),
];

/// Floating white navbar — icon + always-visible label under every tab
/// (Socios-style), with the active tab highlighted in the brand colour.
class AppBottomNav extends StatelessWidget {
  final int active;
  final ValueChanged<int> onTap;
  const AppBottomNav({super.key, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Add the bottom safe-area inset so the floating bar clears the Android
    // gesture / navigation bar now that the app draws edge-to-edge.
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 10 + bottomInset),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.nav),
          boxShadow: const [
            BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < kNavDestinations.length; i++)
              Expanded(
                child: _NavItem(
                  dest: kNavDestinations[i],
                  selected: i == active,
                  onTap: () {
                    if (i != active) HapticFeedback.selectionClick();
                    onTap(i);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavDest dest;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.dest, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.brandPrimary : AppColors.textLight;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dest.iconData != null)
              Icon(dest.iconData, size: 22, color: color)
            else
              Svg(dest.icon!, size: 22, color: color),
            const SizedBox(height: 3),
            Text(tr(dest.label),
                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                style: AppText.caption1.copyWith(
                    color: color, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
