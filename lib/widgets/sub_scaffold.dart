import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Scaffold for pushed detail screens with a back title bar.
class SubScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? bottomBar;
  final Color? background;
  final EdgeInsetsGeometry padding;
  const SubScaffold({
    super.key,
    required this.title,
    required this.children,
    this.bottomBar,
    this.background,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
            Expanded(child: ListView(padding: padding.add(EdgeInsets.only(bottom: bottomBar == null ? MediaQuery.of(context).padding.bottom : 0)), children: children)),
            if (bottomBar != null)
              SafeArea(top: false, child: Padding(padding: const EdgeInsets.all(20), child: bottomBar!)),
          ],
        ),
      ),
    );
  }

  Widget _bar(BuildContext context) {
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
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}
