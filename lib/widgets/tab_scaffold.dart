import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';
import 'ios_chrome.dart';

/// Standard header used across secondary tabs: title + optional trailing bell.
class TabHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBell;
  final Widget? trailing;
  const TabHeader(this.title, {super.key, this.subtitle, this.showBell = true, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.h2.copyWith(fontSize: 26)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppText.body2.copyWith(color: AppColors.textLight)),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showBell)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(36)),
              child: const Center(child: Svg('bell_dot', size: 20)),
            ),
        ],
      ),
    );
  }
}

/// Wraps a secondary tab's scroll content with status bar + bottom padding
/// (the floating navbar is supplied by MainShell).
class TabScaffold extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  const TabScaffold({super.key, required this.children, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const IOSStatusBar(),
        const SizedBox(height: 12),
        ...children,
      ],
    );
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: onRefresh == null
            ? list
            : RefreshIndicator(onRefresh: onRefresh!, color: AppColors.brandPrimary, child: list),
      ),
    );
  }
}
