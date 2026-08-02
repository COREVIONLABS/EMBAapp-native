import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../model/voucher_store.dart';
import 'voucher_screen.dart';
import 'redeem_screen.dart';
import '../l10n/strings.dart';

/// "My Vouchers" — every reward the fan redeemed points for. Each is a code they
/// take to the real Fanshop / ticket shop / counter; the status flips to "used"
/// once the staff PIN confirms it.
class MyVouchersScreen extends StatelessWidget {
  const MyVouchersScreen({super.key});

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
            return Column(children: [
              for (final v in list) ...[_row(context, v), const SizedBox(height: 10)],
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
                const SizedBox(width: 6),
                Expanded(child: Text(tr('Show the code in the official shop or at the counter to redeem.'),
                    style: AppText.caption1.copyWith(color: AppColors.textLight))),
              ]),
            ]);
          },
        ),
      ],
    );
  }

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
            : Pill(color: AppColors.successBg, child: Text(tr('Open'), style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w700))),
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
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RedeemScreen()))),
        ),
      ]),
    );
  }
}
