import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/floating_sponsor_ads.dart';
import 'screens/home_matchday.dart';
import 'screens/redeem_screen.dart';
import 'screens/gewinnen_screen.dart';
import 'screens/fanplus_screen.dart';
import 'screens/profile_screen.dart';
import 'model/fan_model.dart';

class MainShell extends StatefulWidget {
  final int initialTab;
  const MainShell({super.key, this.initialTab = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _tab = widget.initialTab;

  @override
  void initState() {
    super.initState();
    // Let screens (e.g. Home round actions) request a tab switch.
    tabRequestNotifier.addListener(_onTabRequest);
  }

  void _onTabRequest() {
    final i = tabRequestNotifier.value;
    if (i != null && i != _tab && mounted) setState(() => _tab = i);
    tabRequestNotifier.value = null;
  }

  @override
  void dispose() {
    tabRequestNotifier.removeListener(_onTabRequest);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tabs = <Widget>[
      HomeMatchdayScreen(),
      RedeemScreen(isTab: true),
      GewinnenScreen(),
      FanPlusScreen(),
      ProfileScreen(),
    ];
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned.fill(child: IndexedStack(index: _tab, children: tabs)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(active: _tab, onTap: (i) => setState(() => _tab = i)),
          ),
          // Floating Pizza Hut ad — Home tab only (kept off the other tabs so
          // it doesn't feel like too much). The McDonald's badge lives on the
          // Vorteile page instead. Gated on ad consent, labelled "Anzeige".
          if (_tab == 0) const Positioned.fill(child: FloatingSponsorAds()),
        ],
      ),
    );
  }
}
