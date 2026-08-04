import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../model/voucher_store.dart';
import 'voucher_screen.dart';
import '../l10n/strings.dart';

/// Sponsor offer detail — opened from a partner promo card. Explains exactly
/// what the fan gets, how to use it and until when, then secures a partner code
/// into the wallet to show at the partner.
class SponsorOfferScreen extends StatelessWidget {
  final Sponsor sponsor;
  const SponsorOfferScreen({super.key, required this.sponsor});

  String get _blurb => switch (sponsor.name) {
        'Veltins' => 'Double Fan Points on every Veltins purchase at the stadium and at participating partners.',
        'Vivawest' => '10% off selected Vivawest offers for S04 fans.',
        'adidas' => '5% of your spend back as Fan Points in the official Fanshop.',
        "Ernsting's" => 'A €5 voucher at Ernsting\'s family from €25 spend.',
        'REWE' => '3× Fan Points on your REWE shop when you show your fan code.',
        _ => 'An exclusive partner offer for S04 fans.',
      };

  void _secure(BuildContext context) {
    final v = voucherStore.issue(title: '${sponsor.name} · ${sponsor.perk}', category: 'Sponsor', points: 0, sponsor: sponsor.name);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => VoucherScreen.fromIssued(v)));
  }

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Partner offer'),
      bottomBar: PrimaryButton(tr('Secure this offer'), onTap: () => _secure(context)),
      children: [
        // Header banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: sponsor.color, borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(sponsor.icon, color: sponsor.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(sponsor.name, style: AppText.h4.copyWith(color: Colors.white)),
                Text(tr('Partner offer'), style: AppText.body3.copyWith(color: Colors.white70)),
              ])),
            ]),
            const SizedBox(height: 18),
            Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(sponsor.perk, style: AppText.label2.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
          ]),
        ),
        const SizedBox(height: 20),
        Text(tr('What you get'), style: AppText.label1),
        const SizedBox(height: 8),
        Text(tr(_blurb), style: AppText.body1.copyWith(color: AppColors.textNormal, height: 1.6, fontSize: 14)),
        const SizedBox(height: 20),
        Text(tr('How it works'), style: AppText.label1),
        const SizedBox(height: 12),
        for (final (i, s) in const [
          'Secure the offer — the code lands in My Vouchers.',
          'Show the code at the partner or at checkout.',
          'Get your points or discount instantly.',
        ].indexed) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(color: AppColors.brandLightest, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text('${i + 1}', style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Padding(padding: const EdgeInsets.only(top: 3), child: Text(tr(s), style: AppText.body2.copyWith(color: AppColors.textNormal)))),
          ]),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        SurfaceCard(
          color: AppColors.brandLightest,
          child: Row(children: [
            Icon(Icons.schedule_rounded, size: 16, color: AppColors.brandPrimary),
            const SizedBox(width: 10),
            Expanded(child: Text(tr('Valid until 30 Jun 2026 · one per fan.'), style: AppText.body3.copyWith(color: AppColors.onAccent))),
          ]),
        ),
      ],
    );
  }
}
