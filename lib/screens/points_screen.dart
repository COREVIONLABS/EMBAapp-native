import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/tab_scaffold.dart';

/// Points tab — History / Missions (Figma 386:7030 / 386:7304).
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
        const TabHeader('Points', subtitle: 'S04 Fan Points'),
        const SizedBox(height: 20),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _PointsHero()),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _Segmented(
            labels: const ['History', 'Missions'],
            index: _seg,
            onChanged: (i) => setState(() => _seg = i),
          ),
        ),
        const SizedBox(height: 16),
        if (_seg == 0) ..._history() else ..._missions(),
      ],
    );
  }

  List<Widget> _history() {
    const rows = [
      ('Matchday check-in', '+120', 'Today · Veltins-Arena', true),
      ('Prediction correct', '+80', 'Yesterday', true),
      ('Redeemed: Home jersey', '-1,500', '2 days ago', false),
      ('Club shop purchase', '+45', 'Last week', true),
      ('Daily spin', '+25', 'Last week', true),
    ];
    return rows
        .map((r) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _PointRow(title: r.$1, pts: r.$2, sub: r.$3, credit: r.$4),
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
                        Text(r.$1, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                        Pill(
                          color: AppColors.successBg,
                          child: Text(r.$2,
                              style: AppText.caption1.copyWith(color: AppColors.success, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: r.$3,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceLowContrast,
                        valueColor: const AlwaysStoppedAnimation(AppColors.brandPrimary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(r.$4, style: AppText.body3Regular),
                  ],
                ),
              ),
            ))
        .toList();
  }
}

class _PointsHero extends StatelessWidget {
  const _PointsHero();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.pointsGradient),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total balance', style: AppText.body2.copyWith(color: Colors.white70)),
          const SizedBox(height: 6),
          Text('2,850', style: AppText.h1.copyWith(color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            children: [
              Pill(
                gradient: const LinearGradient(colors: AppColors.goldGradient),
                child: Text('Superfan tier', style: AppText.caption1.copyWith(color: AppColors.textDarker)),
              ),
              const SizedBox(width: 8),
              Pill(
                color: AppColors.brandDark,
                child: Text('+430 this week', style: AppText.caption1.copyWith(color: AppColors.textLightest)),
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
      decoration: BoxDecoration(
        color: AppColors.surfaceMinimal,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
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
                    boxShadow: i == index
                        ? const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1))]
                        : null,
                  ),
                  child: Center(
                    child: Text(labels[i],
                        style: AppText.body2.copyWith(
                            color: i == index ? AppColors.brandPrimary : AppColors.textLight,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PointRow extends StatelessWidget {
  final String title;
  final String pts;
  final String sub;
  final bool credit;
  const _PointRow({required this.title, required this.pts, required this.sub, required this.credit});
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: credit ? AppColors.successBg : AppColors.brandLightest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(credit ? Icons.add_rounded : Icons.redeem_rounded,
                color: credit ? AppColors.success : AppColors.brandPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                const SizedBox(height: 2),
                Text(sub, style: AppText.body3Regular),
              ],
            ),
          ),
          Text(pts,
              style: AppText.label2.copyWith(
                  color: credit ? AppColors.success : AppColors.textDarker, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
