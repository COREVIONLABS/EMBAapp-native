import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../widgets/animated_count.dart';
import 'spin_screen.dart';
import 'scratch_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _header(),
          const SizedBox(height: 16),
          _pointsCard(),
          const SizedBox(height: 20),
          _gamesRow(context),
          const SizedBox(height: 22),
          _challengeCard(),
          const SizedBox(height: 14),
          _communityCard(),
        ],
      ),
    );
  }

  Widget _header() => Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.navy, shape: BoxShape.circle,
              border: Border.all(color: AppColors.navy, width: 2),
            ),
            alignment: Alignment.center,
            child: const Text('S04', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          const Spacer(),
          Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(color: Color(0xFFEFF2F7), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none, color: AppColors.ink),
          ),
        ],
      );

  Widget _pointsCard() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [AppColors.navy, AppColors.navyDark],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(0.30), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('S04 Fan Points', style: TextStyle(color: Colors.white70, fontSize: 15)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.workspace_premium, color: AppColors.gold, size: 16),
                    SizedBox(width: 6),
                    Text('Superfan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedCount(
              value: appState.points,
              style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w800, height: 1.1),
            ),
            const SizedBox(height: 12),
            Row(children: [
              _chip('${appState.tickets} Raffle Tickets', Colors.white.withOpacity(0.15), Colors.white),
              const SizedBox(width: 8),
              _chip('3x Stadium Boost', AppColors.gold, AppColors.navyDark),
            ]),
          ],
        ),
      );

  Widget _chip(String t, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(t, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
      );

  Widget _gamesRow(BuildContext context) {
    final items = [
      ('🎡', 'Daily Spin', () => _open(context, const SpinScreen())),
      ('🎫', 'Scratch Card', () => _open(context, const ScratchScreen())),
      ('🔮', 'Predictions', () => _soon(context)),
      ('🎁', 'Rewards', () => _soon(context)),
    ];
    return Row(
      children: [
        for (final it in items)
          Expanded(
            child: GestureDetector(
              onTap: it.$3,
              child: Column(
                children: [
                  Container(
                    height: 74,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(color: const Color(0xFFEAF1FF), borderRadius: BorderRadius.circular(18)),
                    alignment: Alignment.center,
                    child: Text(it.$1, style: const TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(height: 6),
                  Text(it.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _challengeCard() => _panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('Weekly Challenge', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              const Spacer(),
              _chip('+50 pts', const Color(0xFFEAF1FF), AppColors.blue),
            ]),
            const SizedBox(height: 10),
            const Text('Spend €50 this week', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 10),
            _progress(0.65, AppColors.blue),
            const SizedBox(height: 8),
            const Text('€32.50 / €50 · 65%', style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
      );

  Widget _communityCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFFE9F7EF), borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Community Goal', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            const SizedBox(height: 8),
            const Text('€32,000 left to unlock Community Bonus', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 10),
            _progress(0.36, AppColors.green),
            const SizedBox(height: 8),
            const Text('€18,000 / €50,000 · 36% collective', style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
      );

  Widget _panel({required Widget child}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECEFF4)),
        ),
        child: child,
      );

  Widget _progress(double v, Color c) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(value: v, minHeight: 8, backgroundColor: const Color(0xFFE7EBF2), color: c),
      );

  void _open(BuildContext c, Widget w) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));
  void _soon(BuildContext c) => ScaffoldMessenger.of(c).showSnackBar(
        const SnackBar(content: Text('Bald verfügbar')),
      );
}
