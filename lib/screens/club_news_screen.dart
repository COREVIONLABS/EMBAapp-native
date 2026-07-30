import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'news_detail_screen.dart';

/// Club News (Figma 2162:5325) — category tabs + compact article rows.
class ClubNewsScreen extends StatefulWidget {
  const ClubNewsScreen({super.key});
  @override
  State<ClubNewsScreen> createState() => _ClubNewsScreenState();
}

class _ClubNewsScreenState extends State<ClubNewsScreen> {
  int _tab = 0;
  static const _tabs = ['All', 'Team', 'Insides', 'Internationals', 'Next'];

  static const _news = <NewsArticle>[
    NewsArticle('Team', 'Königsblau secures vital home win against Bayern',
        'Two second-half goals send the VELTINS-Arena into raptures.', '2h ago', [
      'Under the floodlights of the VELTINS-Arena, Schalke delivered one of the performances of the season, overturning an early deficit to beat Bayern Munich 3-1 in front of a sold-out home crowd.',
      'The turning point came just after the hour mark, when a driving run down the left unlocked the visitors’ defence and set up the equaliser. From there, the Royal Blues never looked back.',
      'The three points lift Schalke into the upper half of the table and provide a timely boost ahead of a demanding run of fixtures.',
    ]),
    NewsArticle('Insides', 'Academy talent signs first professional contract',
        'The 18-year-old midfielder commits his future to the club.', '5h ago', [
      'A product of the famed Knappenschmiede academy has put pen to paper on his first professional deal, tying him to the club until 2029.',
      'The midfielder has been a standout in the youth ranks and trained regularly with the first team this season.',
    ]),
    NewsArticle('Team', 'New Fan+ experiences announced for the spring',
        'Members gain access to exclusive behind-the-scenes events.', 'Yesterday', [
      'The club has unveiled a fresh slate of Fan+ experiences, including training-ground visits, player meet-and-greets and priority access to matchday hospitality.',
      'Fan+ members will be the first to book, with general availability opening the following week.',
    ]),
    NewsArticle('Internationals', 'Three Royal Blues called up for national duty',
        'International recognition for the in-form trio.', '2d ago', [
      'Three members of the squad have received call-ups for the upcoming international window, a reflection of their strong club form.',
      'The club wishes them well and looks forward to welcoming them back ahead of the next league fixture.',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final list = _tab == 0 ? _news : _news.where((n) => n.category == _tabs[_tab]).toList();
    return SubScaffold(
      title: 'Club News',
      children: [
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                    color: i == _tab ? AppColors.brandPrimary : AppColors.surfaceMinimal,
                    borderRadius: BorderRadius.circular(AppRadii.pill)),
                child: Text(_tabs[i],
                    style: AppText.body2.copyWith(
                        color: i == _tab ? Colors.white : AppColors.textNormal, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Center(child: Text('No articles in this category yet.', style: AppText.body2.copyWith(color: AppColors.textLight))),
          )
        else
          for (final n in list) ...[_NewsRow(n), const SizedBox(height: 10)],
      ],
    );
  }
}

class _NewsRow extends StatelessWidget {
  final NewsArticle n;
  const _NewsRow(this.n);
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(8),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewsDetailScreen(article: n))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.pointsGradient),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.newspaper_rounded, color: Colors.white24, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(n.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body2.copyWith(color: AppColors.textDarker, height: 1.25)),
                const SizedBox(height: 4),
                Text(n.teaser, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
                const SizedBox(height: 6),
                Row(children: [
                  Text(n.category, style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
                  Text('  ·  ${n.date}', style: AppText.caption1.copyWith(color: AppColors.textLight)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
