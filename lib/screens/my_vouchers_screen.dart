import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../model/voucher_store.dart';
import 'voucher_screen.dart';
import '../l10n/strings.dart';

/// "My Vouchers" — every reward the fan redeemed points for. Each is a code they
/// take to the real Fanshop / ticket shop / counter; the status flips to "used"
/// once the staff PIN confirms it. Open vs. used split behind a toggle so a long
/// history never buries the codes that are still redeemable.
class MyVouchersScreen extends StatefulWidget {
  const MyVouchersScreen({super.key});
  @override
  State<MyVouchersScreen> createState() => _MyVouchersScreenState();
}

class _MyVouchersScreenState extends State<MyVouchersScreen> {
  int _tab = 0; // 0 = open, 1 = used

  IconData _icon(String category) => switch (category) {
        'Fanshop' => Icons.checkroom_rounded,
        'Tickets' => Icons.confirmation_number_rounded,
        'Food & Drink' => Icons.fastfood_rounded,
        'Experiences' => Icons.stadium_rounded,
        _ => Icons.card_giftcard_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('My Vouchers'),
      children: [
        AnimatedBuilder(
          animation: voucherStore,
          builder: (context, _) {
            final list = voucherStore.vouchers;
            if (list.isEmpty) return _empty(context);
            final open = list.where((v) => !v.redeemed).toList();
            final used = list.where((v) => v.redeemed).toList();
            final showing = _tab == 0 ? open : used;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SegmentedToggle(
                labels: ['${tr('Open')} (${open.length})', '${tr('Used')} (${used.length})'],
                selected: _tab,
                onTap: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: 16),
              if (showing.isEmpty)
                _tabEmpty()
              else ...[
                for (final v in showing) ...[_row(context, v), const SizedBox(height: 10)],
                if (_tab == 0) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
                    const SizedBox(width: 6),
                    Expanded(child: Text(tr('Show the code in the shop or at the partner to redeem.'),
                        style: AppText.caption1.copyWith(color: AppColors.textLight))),
                  ]),
                ],
              ],
            ]);
          },
        ),
      ],
    );
  }

  Widget _tabEmpty() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Column(children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.surfaceMinimal, shape: BoxShape.circle), child: Icon(_tab == 0 ? Icons.confirmation_number_outlined : Icons.check_circle_outline_rounded, size: 30, color: AppColors.textLight)),
          const SizedBox(height: 14),
          Text(_tab == 0 ? tr('No open vouchers') : tr('Nothing used yet'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(_tab == 0 ? tr('Redeem points for a voucher to see it here.') : tr('Redeemed vouchers move here once the code is used.'), textAlign: TextAlign.center, style: AppText.body3Regular),
        ])),
      );

  Widget _row(BuildContext context, IssuedVoucher v) {
    return SurfaceCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VoucherScreen.fromIssued(v))),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)),
          child: Icon(_icon(v.category), color: AppColors.brandPrimary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr(v.title), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('${v.code} · ${v.date}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
        ])),
        const SizedBox(width: 8),
        v.redeemed
            ? Pill(color: AppColors.surfaceMinimal, child: Text(tr('Used'), style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700)))
            : Pill(color: AppColors.successBg, child: Text(tr('Ready'), style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w700))),
      ]),
    );
  }

  Widget _empty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, shape: BoxShape.circle),
          child: Icon(Icons.confirmation_number_outlined, size: 34, color: AppColors.textLight),
        ),
        const SizedBox(height: 16),
        Text(tr('No vouchers yet'), style: AppText.label1),
        const SizedBox(height: 6),
        Text(tr('Redeem your points for a voucher, then show the code in the shop.'),
            textAlign: TextAlign.center, style: AppText.body2.copyWith(color: AppColors.textLight)),
        const SizedBox(height: 20),
        SizedBox(
          width: 220,
          child: PrimaryButton('${tr('Redeem')} ${FanModel.pointsFormatted} ${tr('pts')}',
              onTap: () {
                // Switch to the Redeem tab rather than stacking a second copy.
                tabRequestNotifier.value = 1;
                Navigator.of(context).popUntil((r) => r.isFirst);
              }),
        ),
      ]),
    );
  }
}
