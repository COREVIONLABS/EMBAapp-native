import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Two ways to earn with Fan+ Pay:
/// - [card]  a co-branded S04 debit card (Club Brugge "Club Pay" style)
/// - [link]  card-linking: keep your own bank, link your existing card and
///           still earn cashback at partners (Auric.cloud style — no bank switch)
enum _PayMode { card, link }

/// Fan+ Pay — the Phase-2 payments programme. Gated behind [cardActiveNotifier]
/// so it only appears when the roadmap state is switched on (Profile → Demo).
class FanPlusPayScreen extends StatefulWidget {
  const FanPlusPayScreen({super.key});

  @override
  State<FanPlusPayScreen> createState() => _FanPlusPayScreenState();
}

class _FanPlusPayScreenState extends State<FanPlusPayScreen> {
  _PayMode _mode = _PayMode.card;
  bool _boostActive = false;

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Fan+ Pay'),
      children: [
        // Preview framing — this is a Season-2 roadmap concept; every figure here
        // is illustrative, not a real financial statement.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, size: 15, color: AppColors.brandPrimary),
            const SizedBox(width: 8),
            Expanded(child: Text(tr('Preview · Season 2 concept — figures shown are illustrative.'), style: AppText.caption1.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w700))),
          ]),
        ),
        const SizedBox(height: 14),
        // ── Choose how you earn: new card vs link your own ──
        _ModeToggle(mode: _mode, onChanged: (m) => setState(() => _mode = m)),
        const SizedBox(height: 14),

        // ── The card (co-branded or linked variant) ──
        _PayCard(mode: _mode),
        const SizedBox(height: 8),
        Center(child: Text(
          _mode == _PayMode.card ? tr('Free S04 card · Apple Pay & Google Pay ready') : tr('Keep your bank · link the card you already have'),
          style: AppText.body3Regular,
        )),
        const SizedBox(height: 16),

        // ── Cashback so far (personal) ──
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
        const SizedBox(height: 12),

        // ── Community give-back counter (Monzo "£28k back to fans" hook) ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00623A), Color(0xFF00351F)]), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.groups_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(tr('Fan+ community'), style: AppText.body3.copyWith(color: Colors.white70)),
            ]),
            const SizedBox(height: 10),
            Text('€128,400', style: AppText.h1.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(tr('given back to Schalke fans this season'), style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Activatable monthly boost (multi-use, expires) ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _boostActive ? AppColors.successBg : AppColors.brandLightest,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: _boostActive ? AppColors.success.withValues(alpha: 0.4) : AppColors.brandPrimary.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(color: (_boostActive ? AppColors.success : AppColors.brandPrimary).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(13)), child: Icon(_boostActive ? Icons.check_rounded : Icons.bolt_rounded, color: _boostActive ? AppColors.success : AppColors.brandPrimary, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Matchday boost: 10% cashback'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(_boostActive ? tr('Active · multi-use · ends in 3 days') : tr('Multi-use in the arena & store · expires soon'), style: AppText.body3Regular),
            ])),
            const SizedBox(width: 10),
            if (_boostActive)
              Pill(color: AppColors.successBg, child: Text(tr('On'), style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800)))
            else
              Tappable(
                onTap: () {
                  setState(() => _boostActive = true);
                  showSuccessSheet(context, title: 'Boost activated!', message: 'Your 10% matchday cashback is live. Use it as often as you like until it expires.');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(999)),
                  child: Text(tr('Activate'), style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 22),

        // ── How it works (3 steps) ──
        Align(alignment: Alignment.centerLeft, child: Text(tr('How Fan+ Pay works'), style: AppText.label1)),
        const SizedBox(height: 12),
        for (final s in [
          _mode == _PayMode.card
              ? (Icons.credit_card_rounded, 'Get your free card', 'A co-branded S04 card in your name — or link your own.')
              : (Icons.add_link_rounded, 'Link your card', 'Keep your bank. Connect the card you already use.'),
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
          Expanded(child: Text(tr('Cards issued with our banking partner, powered by Mastercard. Rates are illustrative for this preview.'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }
}

/// Segmented toggle between a new co-branded card and linking your own.
class _ModeToggle extends StatelessWidget {
  final _PayMode mode;
  final ValueChanged<_PayMode> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(children: [
        _seg(context, _PayMode.card, tr('Fan+ Pay card')),
        _seg(context, _PayMode.link, tr('Link my card')),
      ]),
    );
  }

  Widget _seg(BuildContext context, _PayMode m, String label) {
    final sel = mode == m;
    return Expanded(
      child: Tappable(
        scale: 0.98,
        onTap: () => onChanged(m),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: sel ? AppColors.surface : Colors.transparent, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: sel ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))] : null),
          child: Text(label, style: AppText.body3.copyWith(color: sel ? AppColors.brandPrimary : AppColors.textLight, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

/// The card visual — full co-branded card, or a "linked card" variant.
class _PayCard extends StatelessWidget {
  final _PayMode mode;
  const _PayCard({required this.mode});
  @override
  Widget build(BuildContext context) {
    final linked = mode == _PayMode.link;
    return AspectRatio(
      aspectRatio: 1.586, // ISO card ratio
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: linked ? const [Color(0xFF263445), Color(0xFF0B111A)] : const [Color(0xFF0055AA), Color(0xFF000D22)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Svg('logo_s04', size: 30),
            const SizedBox(width: 10),
            Text(linked ? tr('Fan+ Pay · linked') : tr('Fan+ Pay'), style: AppText.label2.copyWith(color: Colors.white)),
            const Spacer(),
            Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(linked ? tr('Linked') : tr('Active'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
          ]),
          const Spacer(),
          Container(width: 42, height: 30, decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 14),
          Text(linked ? '•••• •••• •••• 4921' : '5241 •••• •••• 0042', style: TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 12),
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(linked ? tr('LINKED CARD') : tr('CARD HOLDER'), style: AppText.caption1.copyWith(color: Colors.white54, fontSize: 8, letterSpacing: 1)),
              Text(tr('MAX MUSTERMANN'), style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ]),
            const Spacer(),
            Text('Mastercard', style: TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
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
