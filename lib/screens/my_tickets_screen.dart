import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/qr_code.dart';

class _MyTicket {
  final String home, away, when, venue, block, row, seat, code;
  const _MyTicket(this.home, this.away, this.when, this.venue, this.block, this.row, this.seat, this.code);
}

const _tickets = [
  _MyTicket('Schalke 04', 'Bayern Munich', 'Sat, Apr 5 · 15:30', 'VELTINS-Arena', 'N23', '12', '104', 'S04-BAY-0405-104'),
  _MyTicket('Schalke 04', 'Eintracht Frankfurt', 'Sun, Apr 14 · 17:30', 'VELTINS-Arena', 'O11', '5', '47', 'S04-SGE-0414-047'),
];

/// My Tickets — same-style addition: digital ticket wallet with QR entry.
class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: 'My Tickets',
      children: [
        if (_tickets.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(child: Text('No tickets yet.', style: AppText.body2.copyWith(color: AppColors.textLight))),
          )
        else
          for (final t in _tickets) ...[_TicketStub(t), const SizedBox(height: 16)],
      ],
    );
  }
}

class _TicketStub extends StatelessWidget {
  final _MyTicket t;
  const _TicketStub(this.t);
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.borderLightest),
      ),
      child: Column(
        children: [
          // Match header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.pointsGradient)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Pill(color: Colors.white24, child: Text('Home', style: AppText.caption1.copyWith(color: Colors.white))),
                const Spacer(),
                Text(t.venue, style: AppText.body3.copyWith(color: Colors.white70)),
              ]),
              const SizedBox(height: 12),
              Text('${t.home} vs. ${t.away}', style: AppText.label1.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text(t.when, style: AppText.body3.copyWith(color: Colors.white70)),
            ]),
          ),
          // Perforation
          Row(children: List.generate(
            28,
            (_) => Expanded(child: Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 2), color: AppColors.borderLightest)),
          )),
          // QR + seat
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLightest)),
                child: QrCode(t.code, size: 96, color: AppColors.brandDarkest),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _kv('Block', t.block),
                  const SizedBox(height: 10),
                  _kv('Row', t.row),
                  const SizedBox(height: 10),
                  _kv('Seat', t.seat),
                ]),
              ),
            ]),
          ),
          const Divider(height: 1, color: AppColors.borderLightest),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text('Show this QR code at the turnstile', style: AppText.body3Regular),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: AppText.body3Regular),
      Text(v, style: AppText.label2.copyWith(color: AppColors.textDarker, fontSize: 16)),
    ]);
  }
}
