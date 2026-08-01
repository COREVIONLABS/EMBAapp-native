import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/fan_model.dart';
import 'leaderboard_screen.dart';
import '../l10n/strings.dart';

/// Public Fan Profile — the visibility layer from the concept: a shareable
/// supporter identity with a verified blue-check for paying members, a
/// membership number, and a "Your Impact" dashboard of engagement stats.
class FanProfileScreen extends StatelessWidget {
  const FanProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Fan Profile'),
      bottomBar: PrimaryButton(tr('Share profile'), onTap: () => showShareSheet(context, subject: tr('Max Mustermann · Schalke Fan'))),
      children: [
        // Identity header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.pointsGradient),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Column(children: [
            Container(
              width: 76, height: 76,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: AppColors.goldGradient)),
              alignment: Alignment.center,
              child: Text(tr('MM'), style: const TextStyle(fontFamily: 'Urbanist', color: AppColors.brandDarkest, fontSize: 26, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(tr('Max Mustermann'), style: AppText.h4.copyWith(color: Colors.white)),
              const SizedBox(width: 6),
              // Verified Supporter blue-check — only paying members get it.
              const Icon(Icons.verified_rounded, color: Color(0xFF4DA3FF), size: 22),
            ]),
            const SizedBox(height: 4),
            Text(tr('Verified Supporter · Member #0042'), style: AppText.body3.copyWith(color: Colors.white70)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
              Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Super Fan'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700))),
              Pill(color: Colors.white24, child: Text('${FanModel.currentTier} · ${FanModel.pointsFormatted} pts', style: AppText.caption1.copyWith(color: Colors.white))),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        Text(tr('Your Impact'), style: AppText.label1),
        const SizedBox(height: 12),
        Row(children: const [
          Expanded(child: _StatCard(icon: Icons.stadium_rounded, value: '18', label: 'Games attended')),
          SizedBox(width: 12),
          Expanded(child: _StatCard(icon: Icons.local_fire_department_rounded, value: '5', label: 'Day streak')),
        ]),
        const SizedBox(height: 12),
        Row(children: const [
          Expanded(child: _StatCard(icon: Icons.sports_soccer_rounded, value: '27,430', label: 'Points this season')),
          SizedBox(width: 12),
          Expanded(child: _StatCard(icon: Icons.check_circle_rounded, value: '73%', label: 'Prediction accuracy')),
        ]),
        const SizedBox(height: 12),
        Row(children: const [
          Expanded(child: _StatCard(icon: Icons.groups_rounded, value: '3', label: 'Friends referred')),
          SizedBox(width: 12),
          Expanded(child: _StatCard(icon: Icons.emoji_events_rounded, value: '#5', label: 'Supporter rank')),
        ]),
        const SizedBox(height: 20),
        // Badges
        Text(tr('Badges'), style: AppText.label1),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _Badge(icon: Icons.verified_rounded, label: 'Verified', color: Color(0xFF4DA3FF)),
              SizedBox(width: 12),
              _Badge(icon: Icons.local_fire_department_rounded, label: 'On Fire', color: AppColors.gold),
              SizedBox(width: 12),
              _Badge(icon: Icons.stadium_rounded, label: 'Season Ticket', color: AppColors.brandPrimary),
              SizedBox(width: 12),
              _Badge(icon: Icons.workspace_premium_rounded, label: 'Super Fan', color: AppColors.gold),
              SizedBox(width: 12),
              _Badge(icon: Icons.star_rounded, label: 'Founding Fan', color: AppColors.brandPrimary),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SurfaceCard(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.leaderboard_rounded, color: AppColors.brandPrimary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Top Supporters'), style: AppText.body2.copyWith(color: AppColors.textDarker)),
              Text(tr("See where you rank this season"), style: AppText.body3Regular),
            ])),
            Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ]),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCard({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.tile), border: Border.all(color: AppColors.borderLightest)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.brandPrimary, size: 22),
        const SizedBox(height: 10),
        Text(value, style: AppText.h4.copyWith(color: AppColors.textDarker)),
        const SizedBox(height: 2),
        Text(tr(label), style: AppText.body3Regular),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12), border: Border.all(color: color, width: 1.5)),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(tr(label), textAlign: TextAlign.center, style: AppText.caption1.copyWith(color: AppColors.textNormal), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}
