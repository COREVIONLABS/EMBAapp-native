import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';

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
class TabScaffold extends StatefulWidget {
  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  /// Optional placeholder shown for a short beat on first mount, so the tab
  /// reveals its content instead of snapping in. Pass a [HubSkeleton] or a
  /// screen-specific skeleton; omit for no loading phase.
  final Widget? skeleton;

  /// When true the content starts at y=0 (behind the OS status bar) so a
  /// coloured top zone can bleed edge-to-edge; the first child must then add
  /// its own top inset. When false the list is padded down by the status-bar
  /// inset so content clears the clock.
  final bool extendTopUnderStatusBar;
  const TabScaffold({super.key, required this.children, this.onRefresh, this.skeleton, this.extendTopUnderStatusBar = false});

  @override
  State<TabScaffold> createState() => _TabScaffoldState();
}

class _TabScaffoldState extends State<TabScaffold> {
  late bool _loading = widget.skeleton != null;

  @override
  void initState() {
    super.initState();
    if (_loading) {
      Future<void>.delayed(const Duration(milliseconds: 750), () {
        if (mounted) setState(() => _loading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final list = ListView(
      padding: EdgeInsets.only(top: widget.extendTopUnderStatusBar ? 0 : topInset + 6, bottom: 120),
      children: [
        if (_loading) widget.skeleton! else ...widget.children,
      ],
    );
    return Container(
      color: AppColors.surface,
      child: widget.onRefresh == null || _loading
          ? list
          : RefreshIndicator(onRefresh: widget.onRefresh!, color: AppColors.brandPrimary, child: list),
    );
  }
}
