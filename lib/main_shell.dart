import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav.dart';
import 'screens/home_matchday.dart';
import 'screens/wallet_screen.dart';
import 'screens/fanshop_screen.dart';
import 'screens/points_screen.dart';
import 'screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  final int initialTab;
  const MainShell({super.key, this.initialTab = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    const tabs = <Widget>[
      HomeMatchdayScreen(),
      FanshopScreen(),
      WalletScreen(),
      PointsScreen(),
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
        ],
      ),
    );
  }
}
