import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../l10n/strings.dart';

/// Invite friends — the cheapest growth channel. Share a personal code; when a
/// friend joins with it, both get +250 points. Prototype: share + copy work,
/// the counters are illustrative.
class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  static const _code = 'MAX-S04';
  static const int _reward = 250;

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Invite friends'),
      children: [
        // Hero.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(children: [
            const Icon(Icons.group_add_rounded, color: AppColors.gold, size: 40),
            const SizedBox(height: 12),
            Text(tr('Bring a friend to S04'), textAlign: TextAlign.center, style: AppText.h4.copyWith(color: Colors.white)),
            const SizedBox(height: 6),
            Text('${tr('You both get')} +$_reward ${tr('points')} ${tr('when they join.')}', textAlign: TextAlign.center, style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 16),
        // Code + copy.
        Text(tr('Your invite code'), style: AppText.label2),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.tile), border: Border.all(color: AppColors.borderLightest)),
          child: Row(children: [
            Expanded(child: Text(_code, style: AppText.h4.copyWith(color: AppColors.textDarker, letterSpacing: 2))),
            Tappable(
              onTap: () async {
                await Clipboard.setData(const ClipboardData(text: _code));
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Code copied'))));
              },
              child: Pill(color: AppColors.brandLightest, child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.copy_rounded, size: 14, color: AppColors.brandPrimary),
                const SizedBox(width: 5),
                Text(tr('Copy'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
              ])),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        PrimaryButton(tr('Share invite'), trailing: const Icon(Icons.ios_share_rounded, size: 18, color: Colors.white), onTap: () => showShareSheet(context, subject: 'Join me on the FC Schalke 04 app — use code $_code and we both get +$_reward points!')),
        const SizedBox(height: 24),
        // How it works.
        Text(tr('How it works'), style: AppText.label1),
        const SizedBox(height: 12),
        for (final s in const [
          (Icons.ios_share_rounded, 'Share your code', 'Send your invite code to a friend'),
          (Icons.person_add_alt_1_rounded, 'They join', 'Your friend signs up with your code'),
          (Icons.savings_rounded, 'You both earn', 'Each of you gets +250 points'),
        ]) ...[
          Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)), child: Icon(s.$1, color: AppColors.brandPrimary, size: 20)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr(s.$2), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              Text(tr(s.$3), style: AppText.body3Regular),
            ])),
          ]),
          const SizedBox(height: 14),
        ],
        // Progress (illustrative).
        SurfaceCard(
          color: AppColors.successBg,
          child: Row(children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(child: Text('3 ${tr('friends joined')} · +750 ${tr('points earned')}', style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w600))),
          ]),
        ),
      ],
    );
  }
}
