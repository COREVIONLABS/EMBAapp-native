import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'fanshop_screen.dart';
import 'tickets_screen.dart';
import 'experiences_screen.dart';
import 'club_news_screen.dart';

class _Result {
  final IconData icon;
  final String title, type;
  final Widget Function() open;
  const _Result(this.icon, this.title, this.type, this.open);
}

/// Search — same-style addition (Figma has a hidden search entry, no screen).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _q = '';

  static const _recent = ['Home Jersey', 'Bayern tickets', 'Museum tour', 'Fan Points'];
  static const _trending = ['Trikot 25/26', 'Matchday deals', 'Meet the players', 'Scarf'];

  final List<_Result> _all = [
    _Result(Icons.shopping_bag_outlined, 'Home Jersey 25/26', 'Fanshop', () => const FanshopScreen()),
    _Result(Icons.shopping_bag_outlined, 'Away Jersey 25/26', 'Fanshop', () => const FanshopScreen()),
    _Result(Icons.confirmation_number_outlined, 'Schalke vs Bayern', 'Tickets', () => const TicketsScreen()),
    _Result(Icons.stadium_outlined, 'Stadium Tour VIP', 'Experiences', () => const ExperiencesScreen()),
    _Result(Icons.stadium_outlined, 'Museum Tour', 'Experiences', () => const ExperiencesScreen()),
    _Result(Icons.newspaper_outlined, 'Win against Bayern', 'News', () => const ClubNewsScreen()),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _q.isEmpty
        ? const <_Result>[]
        : _all.where((r) => r.title.toLowerCase().contains(_q.toLowerCase())).toList();
    return SubScaffold(
      title: 'Search',
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
          child: Row(children: [
            const Icon(Icons.search_rounded, size: 20, color: AppColors.textLight),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (v) => setState(() => _q = v),
                style: AppText.body2.copyWith(color: AppColors.textDarker),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Search the app...',
                  hintStyle: AppText.body2.copyWith(color: AppColors.textLight),
                ),
              ),
            ),
            if (_q.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() {
                  _controller.clear();
                  _q = '';
                }),
                child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textLight),
              ),
          ]),
        ),
        const SizedBox(height: 20),
        if (_q.isEmpty) ...[
          _chips('Recent', _recent),
          const SizedBox(height: 22),
          _chips('Trending', _trending),
        ] else if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Center(child: Text('No results for “$_q”.', style: AppText.body2.copyWith(color: AppColors.textLight))),
          )
        else
          for (final r in results) ...[_ResultRow(r), const SizedBox(height: 8)],
      ],
    );
  }

  Widget _chips(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.label2),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in items)
              GestureDetector(
                onTap: () => setState(() {
                  _controller.text = s;
                  _q = s;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(title == 'Recent' ? Icons.history_rounded : Icons.trending_up_rounded, size: 15, color: AppColors.textLight),
                    const SizedBox(width: 6),
                    Text(s, style: AppText.body2.copyWith(color: AppColors.textNormal)),
                  ]),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final _Result r;
  const _ResultRow(this.r);
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => r.open())),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(11)),
          child: Icon(r.icon, size: 20, color: AppColors.brandPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(r.title, style: AppText.body2.copyWith(color: AppColors.textDarker))),
        Text(r.type, style: AppText.caption1.copyWith(color: AppColors.textLight)),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textLight),
      ]),
    );
  }
}
