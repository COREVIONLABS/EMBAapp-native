import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Fan+ Pay — the Phase-2 co-branded card programme (Club Brugge "Club Pay"
/// inspired, S04-branded). A real-money card that earns cashback at club
/// partners: request the card, pay at partners, get money back automatically.
///
/// This whole feature is gated behind [cardActiveNotifier] so it only appears
/// when the roadmap state is switched on (Profile → Demo / Preview).
class FanPlusPayScreen extends StatefulWidget {
  const FanPlusPayScreen({super.key});

  @override
  State<FanPlusPayScreen> createState() => _FanPlusPayScreenState();
}

class _FanPlusPayScreenState extends State<FanPlusPayScreen> {
  // Prototype state: has the fan already ordered the card?
  bool _ordered = true;

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Fan+ Pay'),
      bottomBar: _ordered
          ? null
          : PrimaryButton(tr('Request my Fan+ Pay card'), onTap: () {
              setState(() => _ordered = true);
              showSuccessSheet(context,
                  title: 'Card on its way!',
                  message: 'Your Fan+ Pay card is being issued. Start earning cashback at S04 partners right away.');
            }),
      children: [
        // ── The card ──
        _PayCard(ordered: _ordered),
        const SizedBox(height: 14),

        if (_ordered) ...[
          // Cashback-so-far strip
          SurfaceCard(
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.savings_rounded, color: AppColors.success, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('€23.40 ${tr('cashback this season')}', style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
                Text(tr('Paid straight back to your Fan+ balance'), style: AppText.body3Regular),
              ])),
            ]),
          ),
          const SizedBox(height: 22),
        ],

        // ── How it works (3 steps, Club Pay style) ──
        Align(alignment: Alignment.centerLeft, child: Text(tr('How Fan+ Pay works'), style: AppText.label1)),
        const SizedBox(height: 12),
        for (final s in const [
          (Icons.credit_card_rounded, 'Request your card', 'A free co-branded S04 card, in your name.'),
          (Icons.storefront_rounded, 'Pay at club partners', 'Use it like any card — in-store or online.'),
          (Icons.autorenew_rounded, 'Cashback comes back', 'Money-back lands automatically after each buy.'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)), child: Icon(s.$1, color: AppColors.brandPrimary, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr(s.$2), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
                Text(tr(s.$3), style: AppText.body3Regular),
              ])),
            ])),
          ),
        const SizedBox(height: 12),

        // ── Where you earn (partner cashback list) ──
        Align(alignment: Alignment.centerLeft, child: Text(tr('Where you earn cashback'), style: AppText.label1)),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(tr('Real money back at official S04 partners.'), style: AppText.body3Regular),
        ),
        for (final p in kPayPartners) ...[
          _PartnerRow(p: p),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Issued with our banking partner. Cashback rates are illustrative for this preview.'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }
}

/// The co-branded card visual (front face).
class _PayCard extends StatelessWidget {
  final bool ordered;
  const _PayCard({required this.ordered});
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586, // ISO card ratio
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0055AA), Color(0xFF000D22)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Svg('logo_s04', size: 30),
            const SizedBox(width: 10),
            Text(tr('Fan+ Pay'), style: AppText.label2.copyWith(color: Colors.white)),
            const Spacer(),
            Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(ordered ? tr('Active') : tr('Preview'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
          ]),
          const Spacer(),
          Container(width: 42, height: 30, decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 14),
          Text(ordered ? '5241  ••••  ••••  0042' : '••••  ••••  ••••  ••••', style: TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 12),
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('CARD HOLDER'), style: AppText.caption1.copyWith(color: Colors.white54, fontSize: 8, letterSpacing: 1)),
              Text(tr('MAX MUSTERMANN'), style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ]),
            const Spacer(),
            Text('VISA', style: TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          ]),
        ]),
      ),
    );
  }
}

class _PartnerRow extends StatelessWidget {
  final PayPartner p;
  const _PartnerRow({required this.p});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.tile), border: Border.all(color: AppColors.borderLightest)),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: p.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(p.icon, color: p.color, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(tr(p.tagline), style: AppText.body3Regular),
        ])),
        const SizedBox(width: 10),
        Pill(
          color: AppColors.successBg,
          child: Text('${p.cashback} ${tr('back')}', style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }
}
