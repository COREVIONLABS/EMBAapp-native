import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';
import 'subscription_screen.dart';

class _Clip {
  final String title, meta, duration;
  final IconData icon;
  final bool locked;
  const _Clip(this.title, this.meta, this.duration, this.icon, {this.locked = false});
}

/// Exclusive Content — video hub (locker-room clips, interviews, behind the
/// scenes). Free users see previews; premium clips are Fan+ gated. Reflects
/// the "Exclusive Content – only in the app" pillar from the Fan+ pitch.
class ExclusiveContentScreen extends StatelessWidget {
  const ExclusiveContentScreen({super.key});

  static const _featured = _Clip(
      'Inside the dressing room — derby win', 'Behind the scenes · Fan+', '4:12', Icons.meeting_room_rounded,
      locked: true);

  static const _clips = [
    _Clip('Terodde: "This club means everything"', 'Interview', '6:30', Icons.mic_rounded),
    _Clip('Matchday walkout — pitchside cam', 'Behind the scenes · Fan+', '2:45', Icons.stadium_rounded, locked: true),
    _Clip('Training ground: set-piece session', 'Training · Fan+', '5:18', Icons.sports_soccer_rounded, locked: true),
    _Clip('Academy talent — first team debut', 'Feature', '3:52', Icons.school_rounded),
    _Clip('Coach mic\'d up vs Dortmund', 'Behind the scenes · Fan+', '7:04', Icons.headset_mic_rounded, locked: true),
  ];

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Exclusive Content'),
      children: [
        // Featured
        GestureDetector(
          onTap: () => _open(context, _featured),
          child: Container(
            height: 190,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.pointsGradient),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Stack(children: [
              const Positioned.fill(child: Center(child: Icon(Icons.play_circle_fill_rounded, size: 64, color: Colors.white24))),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.brandDarkest.withValues(alpha: 0.8)],
                    ),
                  ),
                ),
              ),
              Positioned(left: 16, top: 16, child: Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Fan+ Exclusive'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700)))),
              Positioned(right: 16, top: 16, child: _durationPill(_featured.duration)),
              Positioned(
                left: 16, right: 16, bottom: 16,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr(_featured.title), style: AppText.label1.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(tr(_featured.meta), style: AppText.body3.copyWith(color: Colors.white70)),
                ]),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        Align(alignment: Alignment.centerLeft, child: Text(tr('Latest clips'), style: AppText.label2)),
        const SizedBox(height: 12),
        for (final c in _clips) ...[_ClipRow(c, onTap: () => _open(context, c)), const SizedBox(height: 10)],
      ],
    );
  }

  void _open(BuildContext context, _Clip c) {
    // A paying member already has access — never upsell them their own content.
    final isMember = tierNotifier.value != 'Free Fan';
    if (c.locked && !isMember) {
      _showUpsell(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr('Now playing')}: ${c.title}'), behavior: SnackBarBehavior.floating));
    }
  }

  void _showUpsell(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.lock_rounded, color: AppColors.gold, size: 34),
          const SizedBox(height: 12),
          Text(tr('This clip is Fan+ exclusive'), style: AppText.h4.copyWith(color: AppColors.textDarker)),
          const SizedBox(height: 6),
          Text(tr('Unlock all locker-room clips, interviews and behind-the-scenes videos with Fan+.'),
              style: AppText.body1.copyWith(color: AppColors.textNormal, height: 1.5, fontSize: 14.5)),
          const SizedBox(height: 20),
          PrimaryButton(tr('See Fan+ Plans'), onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
          }),
        ]),
      ),
    );
  }

  static Widget _durationPill(String d) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.brandDarkest.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.play_arrow_rounded, size: 13, color: Colors.white),
          const SizedBox(width: 2),
          Text(d, style: AppText.caption1.copyWith(color: Colors.white, fontSize: 11)),
        ]),
      );
}

class _ClipRow extends StatelessWidget {
  final _Clip c;
  final VoidCallback onTap;
  const _ClipRow(this.c, {required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(10),
      onTap: onTap,
      child: Row(children: [
        Stack(children: [
          Container(
            width: 108, height: 68,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(10)),
            child: Icon(c.locked ? Icons.lock_rounded : Icons.play_circle_fill_rounded, color: Colors.white70, size: c.locked ? 24 : 30),
          ),
          Positioned(right: 4, bottom: 4, child: ExclusiveContentScreen._durationPill(c.duration)),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(c.title), maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, height: 1.25)),
            const SizedBox(height: 4),
            Row(children: [
              if (c.locked) ...[
                const Icon(Icons.lock_rounded, size: 12, color: AppColors.gold),
                const SizedBox(width: 4),
              ],
              Flexible(child: Text(tr(c.meta), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular)),
            ]),
          ]),
        ),
      ]),
    );
  }
}
