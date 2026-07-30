import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/tab_scaffold.dart';
import '../l10n/strings.dart';

enum _Tier { free, supporter, superfan }

/// Wallet (Figma 2145:7678 Free / 7873 Supporter / 8022 Superfan): virtual
/// card, card actions, points/tickets, physical-card upsell, transactions.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  _Tier _tier = _Tier.superfan;

  @override
  Widget build(BuildContext context) {
    final hasCard = _tier != _Tier.free;
    return TabScaffold(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Svg('logo_s04', size: 36),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(36)),
                child: const Center(child: Svg('bell_dot', size: 20)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Tier switcher (prototype: preview each membership state)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
            child: Row(children: [
              for (final t in _Tier.values)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tier = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                          color: t == _tier ? AppColors.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadii.pill)),
                      child: Center(
                        child: Text(tr(_tierName(t)),
                            style: AppText.body3.copyWith(
                                color: t == _tier ? AppColors.brandPrimary : AppColors.textLight,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: hasCard ? _VirtualCard(superfan: _tier == _Tier.superfan) : const _LockedCard()),
        const SizedBox(height: 16),
        if (hasCard) const _CardActions(),
        if (hasCard) const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.monetization_on_rounded, value: '12,450', label: tr('Points'))),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.confirmation_number_rounded, value: '12', label: tr('Tickets'))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_tier != _Tier.superfan)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFFFFF3DC), borderRadius: BorderRadius.circular(AppRadii.tile)),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 22),
                  const SizedBox(width: 10),
                  Expanded(child: Text(tr('Upgrade to Physical Card'), style: AppText.body2.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700))),
                  Text(tr('€9.99/mo'), style: AppText.body3.copyWith(color: AppColors.textDark)),
                  const SizedBox(width: 4),
                  const Svg('arrow_right', size: 16),
                ],
              ),
            ),
          ),
        if (_tier != _Tier.superfan) const SizedBox(height: 24),
        if (_tier == _Tier.superfan) const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Text(tr('Recent Transactions'), style: AppText.label2),
            const SizedBox(width: 6),
            Text(tr('(Sponsors Only)'), style: AppText.body3Regular),
          ]),
        ),
        const SizedBox(height: 12),
        ...[
          ('Nike Store', 'Today · 14:30', '-€84.00', '+252 pts', Color(0xFF111111)),
          ("Macy's Shop", 'Yesterday', '-€45.00', '+90 pts', Color(0xFFE21836)),
          ('Starbucks', 'Mon 12 Feb', '-€12.50', '+25 pts', Color(0xFF00704A)),
          ('Puma', 'Sun 11 Feb', '-€12.50', '+25 pts', Color(0xFF1A2432)),
        ].map((t) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _TxTile(brand: t.$1, date: t.$2, amount: t.$3, pts: t.$4, color: t.$5),
            )),
      ],
    );
  }

  String _tierName(_Tier t) => switch (t) {
        _Tier.free => 'Free',
        _Tier.supporter => 'Supporter',
        _Tier.superfan => 'Superfan',
      };
}

/// Free state — no active card yet.
class _LockedCard extends StatelessWidget {
  const _LockedCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMinimal,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.borderLightest),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.credit_card_off_rounded, size: 34, color: AppColors.textLight),
          const SizedBox(height: 10),
          Text(tr('No active card yet'), style: AppText.body2.copyWith(color: AppColors.textNormal)),
          const SizedBox(height: 12),
          PrimaryButton(tr('Activate S04 Card'), height: 44, onTap: () {}),
        ],
      ),
    );
  }
}

class _VirtualCard extends StatelessWidget {
  final bool superfan;
  const _VirtualCard({this.superfan = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0A2A5E), Color(0xFF002F63)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -40,
            child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04))),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('S04 FAN VIRTUAL CARD'), style: AppText.caption1.copyWith(color: Colors.white70, letterSpacing: 1)),
                  Text(tr('VISA'), style: AppText.label2.copyWith(color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 8),
              Pill(
                gradient: const LinearGradient(colors: AppColors.goldGradient),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(tr(superfan ? 'Superfan' : 'Virtual'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest)),
              ),
              const Spacer(),
              Text(tr('••••   ••••   ••••   4821'),
                  style: AppText.label1.copyWith(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.w700)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('MAX MUSTERMANN'), style: AppText.body3.copyWith(color: Colors.white)),
                  Text(tr('03/28'), style: AppText.body3.copyWith(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardActions extends StatelessWidget {
  const _CardActions();
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.ac_unit_rounded, 'Freeze'),
      (Icons.visibility_outlined, 'Reveal'),
      (Icons.tune_rounded, 'Limits'),
      (Icons.more_horiz_rounded, 'More'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final it in items)
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(14)),
                    child: Icon(it.$1, color: AppColors.brandPrimary, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(it.$2, style: AppText.body3),
                ],
              ),
            ),
        ],
      ),
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
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppText.label1.copyWith(color: AppColors.textDarker)),
              Text(label, style: AppText.body3Regular),
            ],
          ),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final String brand;
  final String date;
  final String amount;
  final String pts;
  final Color color;
  const _TxTile({required this.brand, required this.date, required this.amount, required this.pts, required this.color});
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(brand.characters.first, style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(brand, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                const SizedBox(height: 2),
                Text(date, style: AppText.body3Regular),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(pts, style: AppText.caption1.copyWith(color: AppColors.success, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
