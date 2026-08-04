import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../model/voucher_store.dart';
import 'my_tickets_screen.dart';
import 'my_vouchers_screen.dart';
import 'my_bookings_screen.dart';
import 'collection_screen.dart';
import 'subscription_screen.dart';
import 'points_history_screen.dart';
import '../l10n/strings.dart';

/// One place for everything a fan "owns": membership card, points balance,
/// tickets, vouchers, bookings and collection — so nothing is scattered.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('My Wallet'),
      children: [
        // Membership card (reactive tier)
        ValueListenableBuilder<String>(
          valueListenable: tierNotifier,
          builder: (context, tier, __) => Tappable(
            scale: 0.98,
            onTap: () => _push(context, const SubscriptionScreen()),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Svg('logo_s04', size: 26),
                  const SizedBox(width: 10),
                  Text(tr('Membership'), style: AppText.body3.copyWith(color: Colors.white70)),
                  const Spacer(),
                  Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Active'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
                ]),
                const SizedBox(height: 18),
                Text(tr(tier), style: AppText.h4.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text('${tr('Member')} #0042 · ${tr('Renews: 28 May 2026')}', style: AppText.body3.copyWith(color: Colors.white70)),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Points balance → history
        SurfaceCard(
          onTap: () => _push(context, const PointsHistoryScreen()),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.hexagon_rounded, color: AppColors.gold, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${FanModel.pointsFormatted} ${tr('pts')}', style: AppText.label2.copyWith(color: AppColors.textDarker)),
              Text('≈ ${FanModel.balanceEuro} · ${tr('View history')}', style: AppText.body3Regular),
            ])),
            Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ]),
        ),
        const SizedBox(height: 20),
        Align(alignment: Alignment.centerLeft, child: Text(tr('Everything you hold'), style: AppText.label1)),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: voucherStore,
          builder: (context, _) => Column(children: [
            _row(context, Icons.confirmation_number_rounded, 'My Tickets', '2 upcoming · tap to show QR', const Color(0xFF1565C0), const MyTicketsScreen()),
            const SizedBox(height: 10),
            _row(context, Icons.card_giftcard_rounded, 'My Vouchers', voucherStore.openCount > 0 ? '${voucherStore.openCount} ${tr('ready to redeem')}' : 'Codes to show in the shop', const Color(0xFF6A1B9A), const MyVouchersScreen(), badge: voucherStore.openCount),
            const SizedBox(height: 10),
            _row(context, Icons.event_available_rounded, 'My Bookings', 'Experiences you reserved', const Color(0xFF00897B), const MyBookingsScreen()),
            const SizedBox(height: 10),
            _row(context, Icons.grid_view_rounded, 'Collection', 'Player stickers & badges', const Color(0xFFC62828), const CollectionScreen()),
          ]),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, IconData icon, String title, String sub, Color color, Widget dest, {int badge = 0}) {
    return SurfaceCard(
      onTap: () => _push(context, dest),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr(title), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          Text(tr(sub), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
        ])),
        if (badge > 0) ...[
          Pill(color: AppColors.successBg, child: Text('$badge', style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800))),
          const SizedBox(width: 6),
        ],
        Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
      ]),
    );
  }
}
