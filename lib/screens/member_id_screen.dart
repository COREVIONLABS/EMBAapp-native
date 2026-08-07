import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/qr_code.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Digital Club ID — the fan's membership card in the app: a scannable QR,
/// member number, tier and heritage year. Shown at the stadium, fanshop and fan
/// events (like Austria Klagenfurt's "1920 Club ID", but on our premium card).
class MemberIdScreen extends StatelessWidget {
  const MemberIdScreen({super.key});

  static const _memberNo = 'S04-1904-04821';
  static const _memberName = 'Max Mustermann';

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Club ID'),
      children: [
        // The membership card.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.pointsGradient),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Svg('logo_s04', size: 40),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('FC Schalke 04'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                Text(tr('Official Club ID · Est. 1904'), style: AppText.caption1.copyWith(color: Colors.white70)),
              ])),
              ValueListenableBuilder<String>(
                valueListenable: tierNotifier,
                builder: (context, tier, __) => Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr(tier), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
              ),
            ]),
            const SizedBox(height: 20),
            // QR in a white plate for scanning.
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.tile)),
                child: const QrCode(_memberNo, size: 150),
              ),
            ),
            const SizedBox(height: 18),
            Text(tr('MEMBER'), style: AppText.caption1.copyWith(color: Colors.white54, letterSpacing: 1.2)),
            const SizedBox(height: 2),
            Text(_memberName, style: AppText.h4.copyWith(color: Colors.white)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('Member no.'), style: AppText.caption1.copyWith(color: Colors.white54)),
                Text(_memberNo, style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(tr('Member since'), style: AppText.caption1.copyWith(color: Colors.white54)),
                Text('2019', style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              ]),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        // What it's for.
        SurfaceCard(
          color: AppColors.brandLightest,
          child: Row(children: [
            Icon(Icons.qr_code_scanner_rounded, color: AppColors.brandPrimary),
            const SizedBox(width: 12),
            Expanded(child: Text(tr('Show this at the stadium, fanshop and fan events to identify yourself and collect points.'),
                style: AppText.body3.copyWith(color: AppColors.onAccent))),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Your Club ID is personal — the code refreshes for each scan in the full app.'),
              style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }
}
