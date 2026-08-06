import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Scaffold for pushed detail screens with a back title bar.
class SubScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? bottomBar;
  final Color? background;
  final EdgeInsetsGeometry padding;
  final bool showBack;
  final Widget? trailing;
  const SubScaffold({
    super.key,
    required this.title,
    required this.children,
    this.bottomBar,
    this.background,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 24),
    this.showBack = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background ?? AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _bar(context),
            // Tab-root screens (no back arrow) sit under the floating bottom
            // nav, so add clearance to their scroll padding.
            Expanded(child: ListView(padding: padding.add(EdgeInsets.only(bottom: (showBack ? 0 : 96) + (bottomBar == null ? MediaQuery.of(context).padding.bottom : 0))), children: children)),
            if (bottomBar != null)
              SafeArea(top: false, child: Padding(padding: const EdgeInsets.all(20), child: bottomBar!)),
          ],
        ),
      ),
    );
  }

  Widget _bar(BuildContext context) {
    if (!showBack) {
      // Tab-root header: no back arrow, title left-aligned, optional trailing.
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: Row(children: [
          Expanded(child: Text(title, style: AppText.h4)),
          if (trailing != null) trailing!,
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDarker),
          ),
          Expanded(
            child: Text(title, textAlign: TextAlign.center, style: AppText.label1),
          ),
          SizedBox(width: 44, child: trailing),
        ],
      ),
    );
  }
}
