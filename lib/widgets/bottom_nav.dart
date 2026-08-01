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
  NavDest(null, 'Membership', iconData: Icons.workspace_premium_outlined),
  NavDest('nav_cup', 'Points'),
  NavDest('nav_profile', 'Profile'),
];

/// Floating white pill navbar, 1:1 with Figma (active item shows label pill).
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
      padding: EdgeInsets.fromLTRB(16, 0, 16, 10 + bottomInset),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.nav),
          boxShadow: const [
            BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < kNavDestinations.length; i++)
              _NavItem(
                dest: kNavDestinations[i],
                selected: i == active,
                onTap: () {
                  if (i != active) HapticFeedback.selectionClick();
                  onTap(i);
                },
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandLightest : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          children: [
            if (dest.iconData != null)
              Icon(dest.iconData, size: 20, color: selected ? AppColors.brandPrimary : AppColors.textNormal)
            else
              Svg(dest.icon!, size: 20, color: selected ? AppColors.brandPrimary : AppColors.textNormal),
            if (selected) ...[
              const SizedBox(width: 6),
              Text(tr(dest.label),
                  style: AppText.body3
                      .copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}
