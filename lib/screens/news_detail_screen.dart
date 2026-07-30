import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../l10n/strings.dart';

class NewsArticle {
  final String category, title, teaser, date;
  final List<String> body;
  const NewsArticle(this.category, this.title, this.teaser, this.date, this.body);
}

/// News Article Detail — same-style addition (Figma has no article page).
class NewsDetailScreen extends StatelessWidget {
  final NewsArticle article;
  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.brandDarkest,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(gradient: LinearGradient(colors: AppColors.pointsGradient)),
                  ),
                  const Center(child: Icon(Icons.newspaper_rounded, size: 72, color: Colors.white24)),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.brandDarkest.withValues(alpha: 0.6)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Pill(color: AppColors.brandLightest, child: Text(article.category, style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 10),
                    Text(article.date, style: AppText.body3Regular),
                  ]),
                  const SizedBox(height: 14),
                  Text(article.title, style: AppText.h4.copyWith(color: AppColors.textDarker, height: 1.25)),
                  const SizedBox(height: 8),
                  Text(article.teaser, style: AppText.body1.copyWith(color: AppColors.textNormal, fontSize: 15.5, height: 1.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 18),
                  for (final p in article.body) ...[
                    Text(p, style: AppText.body1.copyWith(color: AppColors.textNormal, height: 1.7, fontSize: 15)),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.favorite_border_rounded, size: 20, color: AppColors.textLight),
                    const SizedBox(width: 6),
                    Text(tr('248'), style: AppText.body3Regular),
                    const SizedBox(width: 20),
                    const Icon(Icons.mode_comment_outlined, size: 19, color: AppColors.textLight),
                    const SizedBox(width: 6),
                    Text(tr('32'), style: AppText.body3Regular),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
