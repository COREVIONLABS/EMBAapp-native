import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

class RootNav extends StatefulWidget {
  const RootNav({super.key});
  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _i = 0;

  Widget _placeholder(String title, IconData icon) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, color: AppColors.muted)),
            const SizedBox(height: 4),
            const Text('Bald verfügbar', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      _placeholder('Wallet', Icons.account_balance_wallet_outlined),
      _placeholder('Fan+', Icons.workspace_premium_outlined),
      _placeholder('Rewards', Icons.emoji_events_outlined),
      _placeholder('Profil', Icons.person_outline),
    ];
    return Scaffold(
      body: SafeArea(bottom: false, child: IndexedStack(index: _i, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.blue.withOpacity(0.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), label: 'Fan+'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), label: 'Rewards'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
