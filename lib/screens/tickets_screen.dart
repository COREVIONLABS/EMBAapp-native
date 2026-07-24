import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';

class _Ticket {
  final String home, away, when, venue;
  final bool isHome, buy;
  const _Ticket(this.home, this.away, this.when, this.venue, this.isHome, this.buy);
}

const _tickets = [
  _Ticket('Schalke 04', 'Bayern Munich', 'Sat, Apr 5 · 15:30', 'VELTINS-Arena', true, false),
  _Ticket('Eintracht HSV', 'Schalke 04', 'Sun, Apr 6 · 18:00', 'Signal Iduna Park', false, true),
  _Ticket('Borussia Dortmund', 'Schalke 04', 'Sat, Apr 13 · 15:30', 'Allianz Arena', false, false),
  _Ticket('Schalke 04', 'Eintracht Frankfurt', 'Sun, Apr 14 · 17:30', 'Red Bull Arena', true, false),
  _Ticket('Schalke 04', 'Bayer Leverkusen', 'Sat, Apr 20 · 15:30', 'Volkswagen Arena', true, false),
];

/// Tickets (Figma 2162:5279).
class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});
  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  int _tab = 0;
  static const _tabs = ['All', 'Home', 'Away'];
  @override
  Widget build(BuildContext context) {
    final list = _tickets.where((t) => _tab == 0 || (_tab == 1 && t.isHome) || (_tab == 2 && !t.isHome)).toList();
    return SubScaffold(
      title: 'Tickets',
      children: [
        _Segmented(labels: _tabs, index: _tab, onChanged: (i) => setState(() => _tab = i)),
        const SizedBox(height: 16),
        for (final t in list) ...[_TicketCard(t), const SizedBox(height: 12)],
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  final _Ticket t;
  const _TicketCard(this.t);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${t.home} vs. ${t.away}', style: AppText.label2.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text('${t.when} · ${t.venue}', style: AppText.body3.copyWith(color: Colors.white70)),
          const SizedBox(height: 12),
          Row(
            children: [
              Pill(color: Colors.white24, child: Text(t.isHome ? 'Home Match' : 'Away Match', style: AppText.caption1.copyWith(color: Colors.white))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: t.buy ? AppColors.gold : Colors.white24, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(t.buy ? 'Buy Now' : 'Earn 100 pts', style: AppText.body3.copyWith(color: t.buy ? AppColors.brandDarkest : Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: t.buy ? AppColors.brandDarkest : Colors.white),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  const _Segmented({required this.labels, required this.index, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: i == index ? AppColors.surface : Colors.transparent, borderRadius: BorderRadius.circular(AppRadii.pill)),
                child: Center(child: Text(labels[i], style: AppText.body2.copyWith(color: i == index ? AppColors.brandPrimary : AppColors.textLight, fontWeight: FontWeight.w700))),
              ),
            ),
          ),
      ]),
    );
  }
}
