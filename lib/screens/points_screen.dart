import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/points_card.dart';
import '../widgets/tab_scaffold.dart';
import 'redeem_screen.dart';
import 'earn_points_screen.dart';
import '../l10n/strings.dart';

/// Points tab — History / Missions (Figma 2145:7321 / 7449).
class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});
  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  int _seg = 0;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      children: [
        // Header: logo + bell
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
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: S04PointsCard(boost: '3x Boost')),
        const SizedBox(height: 16),
        // Use your points banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.goldGradient),
              borderRadius: BorderRadius.circular(AppRadii.tile),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('Use your points'), style: AppText.label2.copyWith(color: AppColors.brandDarkest)),
                      const SizedBox(height: 2),
                      Text(tr('Points are ready to use'), style: AppText.body3.copyWith(color: AppColors.textDark)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RedeemScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.brandDarkest, borderRadius: BorderRadius.circular(999)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(tr('Redeem'), style: AppText.body3.copyWith(color: Colors.white)),
                      const SizedBox(width: 4),
                      const Svg('arrow_left', size: 14),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EarnPointsScreen())),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.trending_up_rounded, color: AppColors.brandPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('Earn more points'), style: AppText.body2.copyWith(color: AppColors.textDarker)),
                Text(tr('See all the ways to collect Fan Points'), style: AppText.body3Regular),
              ])),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _Segmented(labels: const ['History', 'Missions'], index: _seg, onChanged: (i) => setState(() => _seg = i)),
        ),
        const SizedBox(height: 12),
        if (_seg == 0) ..._history() else ..._missions(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            onTap: () {},
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.brandDarkest, borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.credit_card_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(tr('S04 Fan Card'), style: AppText.body2.copyWith(color: AppColors.textDarker)),
                  const SizedBox(width: 6),
                  Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), child: Text(tr('Coming Season 2'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700, fontSize: 10))),
                ]),
                Text(tr('Points on every spend — join the waitlist'), style: AppText.body3Regular),
              ])),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
            ]),
          ),
        ),
      ],
    );
  }

  List<Widget> _history() {
    const rows = [
      ('Adidas Store Purchase', 'Today', '+252 pts', true),
      ('Daily Spin Win', 'Today', '+50 pts', true),
      ('Mission Complete: Spend €200', 'Yesterday', '+100 pts', true),
      ('Match Prediction (Correct)', 'Saturday', '+75 pts', true),
      ('Redeemed: Home Jersey', 'Thursday', '-1,500 pts', false),
    ];
    return rows
        .map((r) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _HistoryRow(title: r.$1, date: r.$2, pts: r.$3, credit: r.$4),
            ))
        .toList();
  }

  List<Widget> _missions() {
    const rows = [
      ('Attend 3 home games', '+300 pts', 0.66, '2 / 3 attended'),
      ('Share on social', '+40 pts', 0.0, 'Not started'),
      ('Refer 5 friends', '+500 pts', 0.4, '2 / 5 referred'),
    ];
    return rows
        .map((r) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr(r.$1), style: AppText.body2.copyWith(color: AppColors.textDarker)),
                        Pill(color: AppColors.successBg, child: Text(r.$2, style: AppText.caption1.copyWith(color: AppColors.success, fontSize: 11))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(value: r.$3, minHeight: 6, backgroundColor: AppColors.surfaceLowContrast, valueColor: const AlwaysStoppedAnimation(AppColors.brandPrimary)),
                    ),
                    const SizedBox(height: 8),
                    Text(tr(r.$4), style: AppText.body3Regular),
                  ],
                ),
              ),
            ))
        .toList();
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
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    boxShadow: i == index ? const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1))] : null,
                  ),
                  child: Center(
                    child: Text(tr(labels[i]), style: AppText.body2.copyWith(color: i == index ? AppColors.brandPrimary : AppColors.textLight, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String title;
  final String date;
  final String pts;
  final bool credit;
  const _HistoryRow({required this.title, required this.date, required this.pts, required this.credit});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: credit ? AppColors.successBg : const Color(0xFFFDE7E7), borderRadius: BorderRadius.circular(10)),
          child: Icon(credit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: credit ? AppColors.success : AppColors.danger, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr(title), style: AppText.body2.copyWith(color: AppColors.textDarker)),
              const SizedBox(height: 2),
              Text(tr(date), style: AppText.body3Regular),
            ],
          ),
        ),
        Text(pts, style: AppText.body2.copyWith(color: credit ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
