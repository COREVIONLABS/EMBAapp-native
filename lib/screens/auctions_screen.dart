import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/auctions.dart';
import '../model/fan_model.dart';
import '../model/voucher_store.dart';
import 'voucher_screen.dart';
import 'buy_points_screen.dart';
import '../l10n/strings.dart';

/// Fan Points auctions hub — bid points on money-can't-buy lots (Socios-style,
/// in the club's own points, no crypto). Pushed from the Gewinnen tab.
class AuctionsScreen extends StatelessWidget {
  const AuctionsScreen({super.key});

  void _open(BuildContext context, Auction a) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => AuctionDetailScreen(id: a.id)));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: auctionStore,
      builder: (context, _) {
        final live = auctionStore.live;
        final past = auctionStore.past;
        return SubScaffold(
          title: tr('Auctions'),
          children: [
            // ── Intro hero ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.pointsGradient),
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.gavel_rounded, color: AppColors.gold, size: 22),
                  const SizedBox(width: 8),
                  Text(tr('Bid with points'), style: AppText.label1.copyWith(color: Colors.white)),
                ]),
                const SizedBox(height: 6),
                Text(tr('Money-can’t-buy items & experiences — win them with your Fan Points.'),
                    style: AppText.body3.copyWith(color: Colors.white70)),
                const SizedBox(height: 14),
                ValueListenableBuilder<int>(
                  valueListenable: pointsNotifier,
                  builder: (context, _, __) => Row(children: [
                    const Icon(Icons.hexagon_rounded, size: 16, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Text('${FanModel.pointsFormatted} ${tr('pts')}', style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 6),
                    Text('${tr('to bid')} · ${tr('≈')} ${FanModel.balanceEuro}', style: AppText.body3.copyWith(color: Colors.white60)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Your status banner (leading / outbid) ──
            if (auctionStore.leadingCount > 0 || live.any((a) => a.outbid)) ...[
              _statusBanner(context, live),
              const SizedBox(height: 16),
            ],

            // ── Live auctions ──
            Align(alignment: Alignment.centerLeft, child: Text(tr('Live now'), style: AppText.label1)),
            const SizedBox(height: 12),
            for (final a in live) ...[
              _AuctionCard(auction: a, onTap: () => _open(context, a)),
              const SizedBox(height: 14),
            ],

            // ── How it works ──
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.tile)),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textLight),
                const SizedBox(width: 10),
                Expanded(child: Text(tr('A bid commits your points. Get outbid and they’re returned — you only spend what you win with.'),
                    style: AppText.body3.copyWith(color: AppColors.textNormal))),
              ]),
            ),

            // ── Past / won ──
            if (past.isNotEmpty) ...[
              const SizedBox(height: 24),
              Align(alignment: Alignment.centerLeft, child: Text(tr('Past auctions'), style: AppText.label1)),
              const SizedBox(height: 12),
              for (final a in past) ...[
                _AuctionCard(auction: a, onTap: () => _open(context, a)),
                const SizedBox(height: 14),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _statusBanner(BuildContext context, List<Auction> live) {
    final outbid = live.where((a) => a.outbid).toList();
    if (outbid.isNotEmpty) {
      final a = outbid.first;
      return Tappable(
        onTap: () => _open(context, a),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(AppRadii.tile), border: Border.all(color: AppColors.danger.withValues(alpha: 0.4))),
          child: Row(children: [
            const Icon(Icons.trending_up_rounded, color: AppColors.danger, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('You’ve been outbid'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
              Text('${tr(a.title)} · ${tr('bid again to win it back')}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: AppColors.textNormal)),
            ])),
            const Icon(Icons.chevron_right_rounded, color: AppColors.danger),
          ]),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(AppRadii.tile), border: Border.all(color: AppColors.success.withValues(alpha: 0.4))),
      child: Row(children: [
        const Icon(Icons.emoji_events_rounded, color: AppColors.success, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(trp('You’re the top bidder on {n} lot(s)', n: '${auctionStore.leadingCount}'),
            style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}

/// Auction list card: image/motif header with countdown + sponsor, then a solid
/// panel with title, current bid, bid count and your status chip.
class _AuctionCard extends StatelessWidget {
  final Auction auction;
  final VoidCallback onTap;
  const _AuctionCard({required this.auction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = auction;
    return Tappable(
      scale: 0.98,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.borderLightest),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Header motif
          SizedBox(
            height: 128,
            child: Stack(fit: StackFit.expand, children: [
              if (a.image != null)
                Image.asset('assets/images/${a.image}.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => _motif(a))
              else
                _motif(a),
              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x33000D22), Color(0x66000D22)]))),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    if (a.sponsor != null)
                      Pill(color: Colors.black.withValues(alpha: 0.45), child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.handshake_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('${tr('powered by')} ${a.sponsor}', style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      ])),
                    const Spacer(),
                    Pill(
                      color: a.ended ? Colors.black.withValues(alpha: 0.45) : AppColors.danger.withValues(alpha: 0.92),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(a.ended ? Icons.check_circle_rounded : Icons.schedule_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(tr(a.endsInLabel), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ]),
                  const Spacer(),
                  Pill(color: Colors.black.withValues(alpha: 0.45), child: Text(tr(a.category), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w600))),
                ]),
              ),
            ]),
          ),
          // Info panel
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr(a.title), style: AppText.label2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(tr(a.item), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
              const SizedBox(height: 14),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr(a.ended ? 'Winning bid' : 'Current bid'), style: AppText.caption1.copyWith(color: AppColors.textLight)),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.hexagon_rounded, size: 15, color: AppColors.brandPrimary),
                    const SizedBox(width: 5),
                    Text('${FanModel.fmtPublic(a.currentBid)} ${tr('pts')}', style: AppText.label1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
                  ]),
                ]),
                const Spacer(),
                _statusChip(a),
              ]),
              const SizedBox(height: 4),
              Text(trp('{n} bids', n: '${a.bidCount}'), style: AppText.caption1.copyWith(color: AppColors.textLight)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _statusChip(Auction a) {
    if (a.won) {
      return Pill(color: AppColors.successBg, child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.emoji_events_rounded, size: 13, color: AppColors.success),
        const SizedBox(width: 4),
        Text(tr('You won'), style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800)),
      ]));
    }
    if (a.ended) return const SizedBox.shrink();
    if (a.leadingByMe) {
      return Pill(color: AppColors.successBg, child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.emoji_events_rounded, size: 13, color: AppColors.success),
        const SizedBox(width: 4),
        Text(tr('You’re winning'), style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800)),
      ]));
    }
    if (a.outbid) {
      return Pill(color: AppColors.dangerBg, child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.trending_up_rounded, size: 13, color: AppColors.danger),
        const SizedBox(width: 4),
        Text(tr('Outbid'), style: AppText.caption1.copyWith(color: AppColors.danger, fontWeight: FontWeight.w800)),
      ]));
    }
    return Pill(color: AppColors.brandLightest, child: Text(tr('Bid now'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)));
  }

  Widget _motif(Auction a) => DecoratedBox(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a.color, Color.lerp(a.color, Colors.black, 0.5)!])),
        child: Center(child: Icon(a.glyph, size: 60, color: Colors.white.withValues(alpha: 0.85))),
      );
}

/// Auction detail — big lot header, live bid + countdown, your status, and the
/// bid action. Ended lots you won can be claimed into My Vouchers.
class AuctionDetailScreen extends StatelessWidget {
  final String id;
  const AuctionDetailScreen({super.key, required this.id});

  void _claim(BuildContext context, Auction a) {
    final v = voucherStore.issue(title: a.title, category: 'Auction', points: a.currentBid, sponsor: a.sponsor, detail: tr('Auction win'));
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => VoucherScreen.fromIssued(v)));
  }

  Future<void> _bid(BuildContext context, Auction a) async {
    if (FanModel.fanPoints < a.nextMinBid) {
      final go = await showConfirmDialog(context,
          title: 'Not enough points',
          message: trp('You need {n} pts to bid. Top up to join the auction?', n: FanModel.fmtPublic(a.nextMinBid)),
          confirmLabel: 'Top up');
      if (go && context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BuyPointsScreen()));
      }
      return;
    }
    final amount = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _BidSheet(auction: a),
    );
    if (amount == null || !context.mounted) return;
    final ok = auctionStore.placeBid(a, amount);
    if (ok && context.mounted) {
      await showSuccessSheet(context,
          title: 'You’re the top bidder!',
          message: trp('Your bid of {n} pts leads. We’ll alert you the moment someone bids higher.', n: FanModel.fmtPublic(amount)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: auctionStore,
      builder: (context, _) {
        final a = auctionStore.byId(id);
        return SubScaffold(
          title: tr('Auction'),
          bottomBar: a.ended
              ? (a.won ? PrimaryButton(tr('Claim your prize'), onTap: () => _claim(context, a)) : SecondaryButton(tr('Auction ended'), onTap: null))
              : PrimaryButton(
                  '${a.leadingByMe ? tr('Raise your bid') : (a.outbid ? tr('Bid again') : tr('Place a bid'))} · ${FanModel.fmtPublic(a.nextMinBid)} ${tr('pts')}',
                  onTap: () => _bid(context, a)),
          children: [
            // Hero
            Container(
              height: 210,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
              child: Stack(fit: StackFit.expand, children: [
                if (a.image != null)
                  Image.asset('assets/images/${a.image}.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => _heroMotif(a))
                else
                  _heroMotif(a),
                const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x22000D22), Color(0x99000D22)]))),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      if (a.sponsor != null)
                        Pill(color: Colors.black.withValues(alpha: 0.45), child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.handshake_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('${tr('powered by')} ${a.sponsor}', style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        ])),
                      const Spacer(),
                      Pill(color: a.ended ? Colors.black.withValues(alpha: 0.45) : AppColors.danger, child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(a.ended ? Icons.check_circle_rounded : Icons.schedule_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(tr(a.endsInLabel), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      ])),
                    ]),
                    const Spacer(),
                    Text(tr(a.category), style: AppText.caption1.copyWith(color: Colors.white70)),
                    const SizedBox(height: 2),
                    Text(tr(a.title), style: AppText.h4.copyWith(color: Colors.white, fontSize: 24)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Text(tr(a.item), style: AppText.body1.copyWith(color: AppColors.textNormal, height: 1.6, fontSize: 14)),
            const SizedBox(height: 18),

            // Bid stat panel
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.card)),
              child: Column(children: [
                Row(children: [
                  Expanded(child: _stat(a.ended ? 'Winning bid' : 'Current bid', '${FanModel.fmtPublic(a.currentBid)} ${tr('pts')}', big: true)),
                  Container(width: 1, height: 40, color: AppColors.borderLightest),
                  Expanded(child: _stat('Total bids', '${a.bidCount}')),
                ]),
                if (!a.ended) ...[
                  const SizedBox(height: 14),
                  Divider(height: 1, color: AppColors.borderLightest),
                  const SizedBox(height: 14),
                  Row(children: [
                    Icon(a.leadingByMe ? Icons.emoji_events_rounded : (a.outbid ? Icons.trending_up_rounded : Icons.gavel_rounded),
                        size: 18, color: a.leadingByMe ? AppColors.success : (a.outbid ? AppColors.danger : AppColors.brandPrimary)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      a.leadingByMe
                          ? trp('You lead with {n} pts committed', n: FanModel.fmtPublic(a.myMaxBid))
                          : (a.outbid ? tr('You were outbid — your points were returned') : tr('No bid from you yet — the lead is open')),
                      style: AppText.body3.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w600),
                    )),
                  ]),
                ],
              ]),
            ),
            const SizedBox(height: 16),

            // Honest note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.tile)),
              child: Row(children: [
                Icon(Icons.shield_rounded, size: 18, color: AppColors.textLight),
                const SizedBox(width: 10),
                Expanded(child: Text(tr('Bids commit your points. If someone outbids you, we return them instantly.'), style: AppText.body3.copyWith(color: AppColors.textNormal))),
              ]),
            ),

            // Won state
            if (a.won) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(AppRadii.card)),
                child: Row(children: [
                  const Icon(Icons.celebration_rounded, color: AppColors.success, size: 24),
                  const SizedBox(width: 12),
                  Expanded(child: Text(tr('Congratulations — you won this lot! Claim it to get your collection code.'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700))),
                ]),
              ),
            ],

            // Presenter demo: preview being outbid (only while you lead).
            if (!a.ended && a.leadingByMe) ...[
              const SizedBox(height: 14),
              Center(
                child: Tappable(
                  onTap: () => auctionStore.simulateRivalBid(a),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(tr('Demo: let a rival outbid me'), style: AppText.caption1.copyWith(color: AppColors.textLight, decoration: TextDecoration.underline)),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _stat(String label, String value, {bool big = false}) => Column(children: [
        Text(tr(label), style: AppText.caption1.copyWith(color: AppColors.textLight)),
        const SizedBox(height: 4),
        Text(value, style: (big ? AppText.h4 : AppText.label1).copyWith(color: AppColors.onAccent, fontSize: big ? 22 : 18, fontWeight: FontWeight.w800)),
      ]);

  Widget _heroMotif(Auction a) => DecoratedBox(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a.color, Color.lerp(a.color, Colors.black, 0.5)!])),
        child: Center(child: Icon(a.glyph, size: 90, color: Colors.white.withValues(alpha: 0.85))),
      );
}

/// Bid bottom sheet: shows your balance and three quick-bid chips built from the
/// lot's minimum increment, then confirms the chosen amount.
class _BidSheet extends StatefulWidget {
  final Auction auction;
  const _BidSheet({required this.auction});

  @override
  State<_BidSheet> createState() => _BidSheetState();
}

class _BidSheetState extends State<_BidSheet> {
  late int _selected = widget.auction.nextMinBid;

  @override
  Widget build(BuildContext context) {
    final a = widget.auction;
    final options = [a.nextMinBid, a.nextMinBid + a.minIncrement, a.nextMinBid + a.minIncrement * 3];
    final affordable = FanModel.fanPoints >= _selected - (a.leadingByMe ? a.myMaxBid : 0);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: AppColors.borderLightest, borderRadius: BorderRadius.circular(2)))),
        Text(tr('Your bid'), style: AppText.label1),
        const SizedBox(height: 4),
        Text('${tr(a.title)} · ${tr('min')} ${FanModel.fmtPublic(a.nextMinBid)} ${tr('pts')}', style: AppText.body3Regular),
        const SizedBox(height: 18),
        Row(children: [
          for (final o in options) ...[
            Expanded(child: Tappable(
              onTap: () => setState(() => _selected = o),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _selected == o ? AppColors.brandPrimary : AppColors.surfaceMinimal,
                  borderRadius: BorderRadius.circular(AppRadii.tile),
                ),
                child: Column(children: [
                  Text(FanModel.fmtPublic(o), style: AppText.body2.copyWith(color: _selected == o ? Colors.white : AppColors.textDarker, fontWeight: FontWeight.w800)),
                  Text(tr('pts'), style: AppText.caption1.copyWith(color: _selected == o ? Colors.white70 : AppColors.textLight)),
                ]),
              ),
            )),
            if (o != options.last) const SizedBox(width: 10),
          ],
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.tile)),
          child: Row(children: [
            Icon(Icons.account_balance_wallet_rounded, size: 16, color: AppColors.textLight),
            const SizedBox(width: 8),
            Expanded(child: Text('${tr('Balance')}: ${FanModel.pointsFormatted} ${tr('pts')}', style: AppText.body3.copyWith(color: AppColors.textNormal))),
            if (a.leadingByMe)
              Text('${tr('committed')} ${FanModel.fmtPublic(a.myMaxBid)}', style: AppText.caption1.copyWith(color: AppColors.textLight)),
          ]),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          affordable ? '${tr('Confirm bid')} · ${FanModel.fmtPublic(_selected)} ${tr('pts')}' : tr('Not enough points'),
          onTap: affordable ? () => Navigator.of(context).pop(_selected) : null,
        ),
      ]),
    );
  }
}
