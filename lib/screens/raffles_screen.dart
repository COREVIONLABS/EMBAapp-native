import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/fan_model.dart';
import 'subscription_screen.dart';
import '../l10n/strings.dart';

/// One monthly prize draw.
class Raffle {
  final String title;
  final String prize;
  final IconData glyph;
  final List<Color> gradient;
  final Duration drawIn;
  final int entries;
  const Raffle(this.title, this.prize, this.glyph, this.gradient, this.drawIn, this.entries);
}

const kRaffles = <Raffle>[
  Raffle('Derby Tombola', '2× VIP tickets — vs Dortmund', Icons.confirmation_number_rounded,
      [Color(0xFF0A2A5E), Color(0xFF000D22)], Duration(days: 3, hours: 6, minutes: 12), 1840),
  Raffle('Play on the pitch', 'Play a match in the VELTINS-Arena', Icons.sports_soccer_rounded,
      [Color(0xFF6A1B9A), Color(0xFF311B92)], Duration(days: 5, hours: 8), 1290),
  Raffle('VIP box on matchday', 'Private box incl. catering', Icons.stadium_rounded,
      [Color(0xFF00695C), Color(0xFF003D33)], Duration(days: 6, hours: 2), 970),
  Raffle('Signed Home Shirt', 'Match-worn, signed by the squad', Icons.checkroom_rounded,
      [Color(0xFFB54708), Color(0xFF7A2E00)], Duration(days: 8, hours: 14), 860),
  Raffle('Meet the team', 'Meet & Greet backstage before kickoff', Icons.groups_rounded,
      [Color(0xFF0A2A5E), Color(0xFF000D22)], Duration(days: 12, hours: 4), 410),
];

/// Cost of one extra lot in points (the "extra lots cost points" economy).
const int kExtraLotCost = 200;

/// Shared live state for the extra lots a fan has bought per draw, so the hub
/// and the detail screen always agree.
class RaffleStore extends ChangeNotifier {
  final Map<int, int> _extra = {};
  int extraFor(int i) => _extra[i] ?? 0;
  void addLot(int i) {
    _extra[i] = extraFor(i) + 1;
    notifyListeners();
  }
}

final raffleStore = RaffleStore();

int raffleFreeLots() => FanModel.perks.freeLots;
int raffleMyEntries(int i) => raffleFreeLots() + raffleStore.extraFor(i);
int raffleTotalEntries(int i) => kRaffles[i].entries + raffleStore.extraFor(i);

/// Buy one extra lot into draw [i]. Guards the balance, spends the points and
/// updates the shared store. Returns whether it succeeded.
Future<bool> buyRaffleLot(BuildContext context, int i) async {
  if (FanModel.fanPoints < kExtraLotCost) {
    await showConfirmDialog(context,
        title: 'Not enough points',
        message: trp('An extra lot costs {n} points. Earn or top up to boost your chances.', n: '$kExtraLotCost'),
        confirmLabel: 'OK');
    return false;
  }
  if (!FanModel.spendPoints(kExtraLotCost)) return false;
  HapticFeedback.mediumImpact();
  raffleStore.addLot(i);
  return true;
}

/// Monthly Tombola hub — luck-based prize draws. Free lots (from membership)
/// auto-enter every open draw; extra lots can be bought with points.
class RafflesScreen extends StatefulWidget {
  const RafflesScreen({super.key});
  @override
  State<RafflesScreen> createState() => _RafflesScreenState();
}

class _RafflesScreenState extends State<RafflesScreen> {
  late final List<DateTime> _ends;
  Timer? _timer;

  int get _freeLots => raffleFreeLots();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _ends = [for (final r in kRaffles) now.add(r.drawIn)];
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _left(int i) {
    final d = _ends[i].difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  bool get _topTier => tierNotifier.value == 'Super Fan';

  void _open(int i) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RaffleDetailScreen(index: i, end: _ends[i])));

  void _showTerms() {
    showConfirmDialog(context,
        title: 'How the tombola works',
        message: tr('Members get free lots each month; free lots enter automatically and extra lots cost points. One lot = one entry, more lots = more chances. No purchase necessary — you can always take part with your free lots. 18+. Winners are drawn at the timer and notified in the app.'),
        confirmLabel: 'Got it');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: raffleStore,
      builder: (context, _) => SubScaffold(
        title: tr('Tombola'),
        children: [
          // One compact status line: your free lots + (unless top tier) a
          // one-tap upgrade shortcut — instead of two stacked info rows.
          Tappable(
            scale: 0.99,
            onTap: _topTier ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
              child: Row(children: [
                Icon(_freeLots == 0 ? Icons.info_outline_rounded : Icons.bolt_rounded, size: 16, color: AppColors.brandPrimary),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  _freeLots == 0
                      ? tr('You have no free lots yet — become a member to enter every draw, or add a lot for points below.')
                      : _topTier
                          ? trp('Your {n} free lots auto-enter every draw — add extra lots for even more chances.', n: '$_freeLots')
                          : trp('Your {n} free lots auto-enter every draw — a higher membership gets you more.', n: '$_freeLots'),
                  style: AppText.body3.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w600))),
                if (!_topTier) Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brandPrimary),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          Text(tr('Tombola of the month'), style: AppText.label1),
          const SizedBox(height: 12),
          Tappable(scale: 0.99, onTap: () => _open(0), child: _featured(0)),
          const SizedBox(height: 22),
          Text(tr('More draws'), style: AppText.label1),
          const SizedBox(height: 12),
          for (var i = 1; i < kRaffles.length; i++) ...[_row(i), const SizedBox(height: 10)],
          const SizedBox(height: 8),
          Tappable(
            onTap: _showTerms,
            child: Row(children: [
              Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Expanded(child: Text(tr('18+ · No purchase necessary — take part with free lots · Terms apply'),
                  style: AppText.caption1.copyWith(color: AppColors.textLight, decoration: TextDecoration.underline))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _featured(int i) {
    final r = kRaffles[i];
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Motif band — brand gradient + a big watermark glyph, with the badges
        // and a live countdown over it.
        SizedBox(
          height: 140,
          child: Stack(fit: StackFit.expand, children: [
            DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: r.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight))),
            Positioned(right: -14, bottom: -22, child: Icon(r.glyph, size: 150, color: Colors.white.withValues(alpha: 0.12))),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Draw of the month'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
                const Spacer(),
                Pill(color: Colors.black.withValues(alpha: 0.4), child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.schedule_rounded, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  CountdownText(_ends[i], style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                ])),
              ]),
            ),
          ]),
        ),
        // Solid info panel — clean, legible text.
        Container(
          color: AppColors.brandDarkest,
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(r.prize), style: AppText.label1.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Row(children: [
              Icon(raffleMyEntries(i) > 0 ? Icons.check_circle_rounded : Icons.info_outline_rounded, size: 15, color: AppColors.gold),
              const SizedBox(width: 6),
              Expanded(child: Text(
                raffleMyEntries(i) > 0 ? trp('You’re in with {n} lots', n: '${raffleMyEntries(i)}') : tr('You have no lots in this draw yet'),
                style: AppText.body3.copyWith(color: Colors.white))),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              const Icon(Icons.local_activity_rounded, size: 15, color: AppColors.gold),
              const SizedBox(width: 6),
              Text('${FanModel.fmtPublic(raffleTotalEntries(i))} ${tr('entries')}', style: AppText.body3.copyWith(color: Colors.white70, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(tr('View draw'), style: AppText.body2.copyWith(color: AppColors.gold, fontWeight: FontWeight.w800)),
              const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 18),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _row(int i) {
    final r = kRaffles[i];
    final left = _left(i);
    return Tappable(
      scale: 0.99,
      onTap: () => _open(i),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
        child: Row(children: [
          // Gradient motif thumbnail with the prize glyph.
          Container(
            width: 58, height: 58,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
            child: Stack(fit: StackFit.expand, children: [
              DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: r.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight))),
              Positioned(right: -6, bottom: -8, child: Icon(r.glyph, size: 44, color: Colors.white.withValues(alpha: 0.18))),
              Center(child: Icon(r.glyph, color: Colors.white, size: 26)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(r.prize), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(children: [
              Pill(color: AppColors.surfaceMinimal, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.schedule_rounded, size: 12, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text('${left.inDays}d ${left.inHours % 24}h', style: AppText.caption1.copyWith(color: AppColors.textNormal, fontWeight: FontWeight.w700)),
              ])),
              const SizedBox(width: 6),
              Pill(color: AppColors.brandLightest, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.local_activity_rounded, size: 11, color: AppColors.brandPrimary),
                const SizedBox(width: 3),
                Text(trp('you: {n}', n: '${raffleMyEntries(i)}'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
              ])),
            ]),
          ])),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
        ]),
      ),
    );
  }
}

/// Full-page draw detail — prize hero, live countdown, your win-chance vs the
/// crowd, how it works, recent entrants, and the add-a-lot action.
class RaffleDetailScreen extends StatefulWidget {
  final int index;
  final DateTime end;
  const RaffleDetailScreen({super.key, required this.index, required this.end});
  @override
  State<RaffleDetailScreen> createState() => _RaffleDetailScreenState();
}

class _RaffleDetailScreenState extends State<RaffleDetailScreen> {
  Timer? _timer;

  static const _recent = ['Max M.', 'Lena K.', 'Jonas B.', 'Aylin Ö.', 'Tim R.'];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  Future<void> _add() async {
    final i = widget.index;
    if (await buyRaffleLot(context, i)) {
      if (!mounted) return;
      await showSuccessSheet(context,
          title: 'Lot added! 🎉',
          message: trp('You now have {n} lots in this draw — more lots, more chances.', n: '${raffleMyEntries(i)}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.index;
    final r = kRaffles[i];
    final d = widget.end.difference(DateTime.now());
    final left = d.isNegative ? Duration.zero : d;
    return AnimatedBuilder(
      animation: raffleStore,
      builder: (context, _) {
        final mine = raffleMyEntries(i);
        final total = raffleTotalEntries(i);
        final chance = total > 0 ? (mine / total * 100) : 0.0;
        return SubScaffold(
          title: tr('Tombola'),
          bottomBar: PrimaryButton(
            '${tr('Add an extra lot')} · $kExtraLotCost ${tr('pts')}',
            color: AppColors.gold, textColor: AppColors.brandDarkest,
            onTap: _add,
          ),
          children: [
            // Prize hero — same premium motif band + solid panel as the hub.
            Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SizedBox(
                  height: 150,
                  child: Stack(fit: StackFit.expand, children: [
                    DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: r.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight))),
                    Positioned(right: -16, bottom: -24, child: Icon(r.glyph, size: 170, color: Colors.white.withValues(alpha: 0.12))),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        if (i == 0) Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Draw of the month'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
                        const Spacer(),
                        Pill(color: Colors.black.withValues(alpha: 0.4), child: Text('${FanModel.fmtPublic(total)} ${tr('entries')}', style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
                      ]),
                    ),
                  ]),
                ),
                Container(
                  color: AppColors.brandDarkest,
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tr(r.prize), style: AppText.h4.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(tr('Money-can’t-buy — won in the monthly draw.'), style: AppText.body3.copyWith(color: Colors.white70)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // Countdown
            Text(tr('Draw in'), style: AppText.label2),
            const SizedBox(height: 10),
            Row(children: [
              _count(_two(left.inDays), 'Days'),
              const SizedBox(width: 10),
              _count(_two(left.inHours % 24), 'Hrs'),
              const SizedBox(width: 10),
              _count(_two(left.inMinutes % 60), 'Min'),
              const SizedBox(width: 10),
              _count(_two(left.inSeconds % 60), 'Sec'),
            ]),
            const SizedBox(height: 20),
            // Your chance
            Text(tr('Your chance'), style: AppText.label1),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.card)),
              child: Column(children: [
                Row(children: [
                  Expanded(child: _stat(trp('{n} lots', n: '$mine'), tr('your entries'))),
                  Container(width: 1, height: 38, color: AppColors.borderLightest),
                  Expanded(child: _stat(FanModel.fmtPublic(total), tr('total entries'))),
                  Container(width: 1, height: 38, color: AppColors.borderLightest),
                  Expanded(child: _stat(chance >= 1 ? '${chance.toStringAsFixed(0)}%' : '${chance.toStringAsFixed(1)}%', tr('win chance'))),
                ]),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(value: (mine / total).clamp(0.0, 1.0), minHeight: 8, backgroundColor: AppColors.surfaceLowContrast, valueColor: const AlwaysStoppedAnimation(AppColors.brandPrimary)),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.bolt_rounded, size: 14, color: AppColors.brandPrimary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
                    _freeNote(),
                    style: AppText.caption1.copyWith(color: AppColors.onAccent),
                  )),
                ]),
              ]),
            ),
            const SizedBox(height: 20),
            // How it works
            Text(tr('How it works'), style: AppText.label1),
            const SizedBox(height: 12),
            for (final (n, s) in const [
              (1, 'Your free lots enter automatically every month.'),
              (2, 'Add extra lots with points — each lot is one more entry.'),
              (3, 'Winners are drawn at the timer and notified in the app.'),
            ]) ...[
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 24, height: 24, decoration: BoxDecoration(color: AppColors.brandLightest, shape: BoxShape.circle), alignment: Alignment.center, child: Text('$n', style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800))),
                const SizedBox(width: 12),
                Expanded(child: Padding(padding: const EdgeInsets.only(top: 2, bottom: 12), child: Text(tr(s), style: AppText.body3.copyWith(color: AppColors.textNormal)))),
              ]),
            ],
            const SizedBox(height: 4),
            // Recent entrants (social proof)
            Text(tr('Recently entered'), style: AppText.label2),
            const SizedBox(height: 10),
            Row(children: [
              SizedBox(
                width: 24.0 * _recent.length + 8,
                height: 34,
                child: Stack(children: [
                  for (var k = 0; k < _recent.length; k++)
                    Positioned(
                      left: k * 22.0,
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(color: AppColors.brandPrimary, shape: BoxShape.circle, border: Border.all(color: AppColors.surface, width: 2)),
                        alignment: Alignment.center,
                        child: Text(_recent[k].characters.first, style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                ]),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(trp('{a} and {n} others just entered', a: _recent.first, n: '${(total / 12).round()}'), style: AppText.body3Regular)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Icon(Icons.info_outline_rounded, size: 13, color: AppColors.textLight),
              const SizedBox(width: 6),
              Expanded(child: Text(tr('18+ · No purchase necessary — take part with free lots · Terms apply'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
            ]),
          ],
        );
      },
    );
  }

  String _freeNote() {
    final free = raffleFreeLots();
    return free > 0
        ? trp('Your {n} free lots are already in — add extra lots to boost your chance.', n: '$free')
        : tr('You have no free lots yet — add a lot with points to enter.');
  }

  Widget _count(String value, String unit) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.tile)),
          child: Column(children: [
            Text(value, style: AppText.h4.copyWith(color: AppColors.textDarker)),
            const SizedBox(height: 2),
            Text(tr(unit), style: AppText.caption1.copyWith(color: AppColors.textLight)),
          ]),
        ),
      );

  Widget _stat(String value, String label) => Column(children: [
        Text(value, style: AppText.h4.copyWith(color: AppColors.textDarker, fontSize: 20)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: AppText.caption1.copyWith(color: AppColors.textLight)),
      ]);
}
