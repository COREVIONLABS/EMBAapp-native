import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import 'raffles_screen.dart';
import 'fan_polls_screen.dart';
import 'season_journey_screen.dart';
import 'daily_spin_screen.dart';
import 'scratch_card_screen.dart';
import '../l10n/strings.dart';

/// "Gewinnen" tab — the play-&-win hub: Tombola, fan votes, quick games and the
/// season journey. A top-level tab (no back button).
class GewinnenScreen extends StatelessWidget {
  const GewinnenScreen({super.key});

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Prizes'),
      showBack: false,
      children: [
        // Tombola — the flagship win.
        Tappable(
          scale: 0.98,
          onTap: () => _push(context, const RafflesScreen()),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0A2A5E), Color(0xFF000D22)]), borderRadius: BorderRadius.circular(AppRadii.card)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Tombola of the month'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
                const Spacer(),
                Text('${FanModel.perks.freeLots} ${tr('free lots')}', style: AppText.caption1.copyWith(color: Colors.white70)),
              ]),
              const SizedBox(height: 14),
              const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 36),
              const SizedBox(height: 10),
              Text(tr('2× VIP tickets — vs Dortmund'), style: AppText.h4.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text(tr('Win VIP tickets, signed gear and more.'), style: AppText.body3.copyWith(color: Colors.white70)),
              const SizedBox(height: 14),
              Row(children: [
                Text(tr('Open Tombola'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        // Fan votes
        Text(tr('Have your say'), style: AppText.label1),
        const SizedBox(height: 12),
        _row(context, Icons.how_to_vote_rounded, 'Fan votes', 'Captain, kit, Player of the Month', const Color(0xFF6A1B9A), const FanPollsScreen()),
        const SizedBox(height: 20),
        // Games
        Text(tr('Quick games'), style: AppText.label1),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _game(context, Icons.casino_rounded, 'Daily Spin', 'Spin to win points', const [Color(0xFF6A1B9A), Color(0xFF311B92)], () => showDailySpin(context))),
          const SizedBox(width: 12),
          Expanded(child: _game(context, Icons.style_rounded, 'Scratch Card', 'Scratch & reveal', const [Color(0xFFB8860B), Color(0xFF7A5901)], () => showScratchCard(context))),
        ]),
        const SizedBox(height: 20),
        // Season journey
        Text(tr('Season'), style: AppText.label1),
        const SizedBox(height: 12),
        _row(context, Icons.route_rounded, 'Road to Gold', 'Your season journey through S04 history', const Color(0xFFEF6C00), const SeasonJourneyScreen()),
      ],
    );
  }

  Widget _row(BuildContext context, IconData icon, String title, String sub, Color color, Widget dest) {
    return SurfaceCard(
      onTap: () => _push(context, dest),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr(title), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          Text(tr(sub), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
        ])),
        Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
      ]),
    );
  }

  Widget _game(BuildContext context, IconData icon, String label, String sub, List<Color> gradient, VoidCallback onTap) {
    return Tappable(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        height: 112,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient), borderRadius: BorderRadius.circular(AppRadii.card)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.gold, size: 22)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(label), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            Text(tr(sub), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ]),
      ),
    );
  }
}
