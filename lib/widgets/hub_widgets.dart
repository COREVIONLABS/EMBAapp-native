import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/fan_model.dart';
import 'app_widgets.dart';
import '../l10n/strings.dart';

/// Reward deal card (strikethrough "3.90 ~~5.70~~" pricing): a photo/motif with
/// a corner badge, a title, and a points price with the old value struck
/// through, plus a quick redeem "+" button.
class DealCard extends StatelessWidget {
  final String title;
  final String category;
  final int oldPts;
  final int newPts;
  final String badge;
  final IconData glyph;
  final Color color;
  final String? image;
  final VoidCallback? onTap;
  const DealCard({
    super.key,
    required this.title,
    required this.category,
    required this.oldPts,
    required this.newPts,
    required this.badge,
    required this.glyph,
    required this.color,
    this.image,
    this.onTap,
  });

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        width: 176,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.borderLightest),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            SizedBox(
              height: 96, width: double.infinity,
              child: Image.asset(
                'assets/images/${image ?? '_none'}.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => DecoratedBox(
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.08)])),
                  child: Center(child: Icon(glyph, size: 40, color: color)),
                ),
              ),
            ),
            Positioned(
              left: 8, top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(AppRadii.chip)),
                child: Text(tr(badge), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr(title), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(tr(category), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Flexible(child: Text('${_fmt(newPts)} ${tr('pts')}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800))),
                  const SizedBox(width: 5),
                  Text(_fmt(oldPts), style: AppText.caption1.copyWith(color: AppColors.textLight, decoration: TextDecoration.lineThrough)),
                ])),
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Full-width editorial hero: a large
/// campaign card with a gradient/photo background, an eyebrow, a big headline
/// and a text CTA. Shows a real photo (`assets/images/<image>.png`) when one is
/// bundled, otherwise a branded gradient with a faint motif glyph.
class HeroBanner extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String cta;
  final IconData glyph;
  final List<Color> gradient;
  final String? image;
  final VoidCallback? onTap;
  const HeroBanner({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.cta,
    required this.glyph,
    this.gradient = AppColors.pointsGradient,
    this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.98,
      onTap: onTap,
      child: Container(
        height: 172,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
        ),
        child: Stack(children: [
          if (image != null)
            Positioned.fill(child: Image.asset('assets/images/$image.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink())),
          Positioned(right: -24, bottom: -24, child: Icon(glyph, size: 168, color: Colors.white.withValues(alpha: 0.12))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(tr(eyebrow), style: AppText.caption1.copyWith(color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
              Text(tr(title), maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.h2.copyWith(color: Colors.white, fontWeight: FontWeight.w800, height: 1.1)),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(tr(cta), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Compact at-a-glance stat chip: a small card
/// with a coloured icon badge, a label and a bold value. Used in a horizontal
/// strip of quick stats.
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  const InfoChip({super.key, required this.icon, required this.label, required this.value, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.96,
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.tile),
          border: Border.all(color: AppColors.borderLightest),
        ),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(label), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: AppColors.textLight, fontSize: 11)),
            const SizedBox(height: 1),
            Text(tr(value), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
          ])),
        ]),
      ),
    );
  }
}

/// Recommendation card ("For you" row): a leading brand/motif
/// tile, a title, a meta line and a discount pill. Two-per-row on the Home feed.
class ForYouCard extends StatelessWidget {
  final String title;
  final String meta;
  final String badge;
  final IconData glyph;
  final Color color;
  final String? image;
  final VoidCallback? onTap;
  const ForYouCard({super.key, required this.title, required this.meta, required this.badge, required this.glyph, required this.color, this.image, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        width: 220,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.borderLightest),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 96,
            width: double.infinity,
            child: Image.asset(
              'assets/images/${image ?? '_none'}.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => DecoratedBox(
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.08)])),
                child: Center(child: Icon(glyph, size: 40, color: color)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr(title), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(tr(meta), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.brandPrimary.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadii.chip)),
                child: Text(tr(badge), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700, fontSize: 11)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Circular sponsor mark. Renders, in order of preference: a real bundled logo
/// (`assets/images/sponsor_<slug>.png`), otherwise a *symbolic category icon*
/// (so a fan sees what the partner is about), otherwise a monogram. The full
/// sponsor name is always shown next to it by the caller.
class SponsorLogo extends StatelessWidget {
  final String name;
  final double size;
  final Color bg;
  final Color fg;
  final IconData? symbol;
  const SponsorLogo({super.key, required this.name, this.size = 52, this.bg = AppColors.brandPrimary, this.fg = Colors.white, this.symbol});

  static String slug(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  Widget _placeholder() => symbol != null
      ? Icon(symbol, color: fg, size: size * 0.46)
      : Text(
          name.characters.first,
          style: TextStyle(fontFamily: 'Urbanist', color: fg, fontSize: size * 0.38, fontWeight: FontWeight.w800),
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/sponsor_${slug(name)}.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }
}

/// Image tile: a soft card that shows a real product/category photo
/// (`assets/images/<image>.png`) filling the card, with the label underneath.
/// Until a photo is bundled it falls back to a colourful, category-tinted motif
/// (a vibrant icon badge on a soft gradient) so the tile already reads as rich
/// and distinct — swapping in the photo later needs no code change.
class HomeImageTile extends StatelessWidget {
  final String image;
  final IconData icon;
  final Color color;
  final String label;
  final double height;
  final VoidCallback? onTap;
  const HomeImageTile({super.key, required this.image, required this.icon, required this.color, required this.label, this.height = 92, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.95,
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: height,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.tile)),
          child: Image.asset('assets/images/$image.png', fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => _motif()),
        ),
        const SizedBox(height: 7),
        Text(tr(label), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: AppText.body3.copyWith(fontSize: 12, color: AppColors.textDarker, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _motif() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withValues(alpha: 0.20), color.withValues(alpha: 0.08)]),
      ),
      child: Stack(children: [
        Positioned(right: -10, bottom: -12, child: Icon(icon, size: 62, color: color.withValues(alpha: 0.16))),
        Center(
          child: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: color, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ]),
    );
  }
}

/// Large gradient promo card (Figma Dell 2194:10203 / lounge 2194:10510 style):
/// sponsor badge + category top-left, a big headline bottom-left, an info
/// button bottom-right. Used in a horizontal carousel.
class BigPromoCard extends StatelessWidget {
  final String sponsor;
  final String category;
  final String headline;
  final Color color;
  final VoidCallback? onTap;
  const BigPromoCard({super.key, required this.sponsor, required this.category, required this.headline, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 176,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, Color.lerp(color, Colors.black, 0.45)!],
          ),
        ),
        child: Stack(children: [
          Positioned(right: -30, top: -30, child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                SponsorLogo(name: sponsor, size: 34, bg: Colors.white, fg: color, symbol: sponsorByName(sponsor)?.icon),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(sponsor, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  Text(tr(category), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: Colors.white70)),
                ])),
              ]),
              const Spacer(),
              Text(headline, style: AppText.h2.copyWith(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
            ]),
          ),
          Positioned(
            right: 12, bottom: 12,
            child: Container(
              width: 26, height: 26,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.22)),
              child: const Icon(Icons.info_outline_rounded, size: 15, color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Featured reward / goal card (Figma 2194:7856): white card, centred icon,
/// title, subtitle, a thin progress bar and a reward value.
class FeaturedGoalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final double progress;
  final String reward;
  final VoidCallback? onTap;
  const FeaturedGoalCard({super.key, required this.icon, required this.title, required this.sub, required this.progress, required this.reward, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.borderLightest),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.brandLightest),
            child: Icon(icon, color: AppColors.brandPrimary, size: 24),
          ),
          const SizedBox(height: 10),
          Text(tr(title), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(tr(sub), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: AppColors.surfaceLowContrast, valueColor: const AlwaysStoppedAnimation(AppColors.brandPrimary)),
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.hexagon_rounded, size: 15, color: AppColors.brandPrimary),
            const SizedBox(width: 5),
            Text(reward, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
          ]),
        ]),
      ),
    );
  }
}

/// Image-style featured card (Figma Top Destinations 2194:9652 / Experiences
/// 2194:10510): a tall card with a branded gradient "photo", a faint category
/// glyph, a category pill and a title/subtitle overlay. Used in a carousel.
class FeaturedImageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String category;
  final IconData glyph;
  final String? badge;
  final List<Color> gradient;
  final VoidCallback? onTap;
  const FeaturedImageCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.glyph,
    required this.gradient,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        width: 170,
        height: 194,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
        ),
        child: Stack(children: [
          // Faint category glyph
          Positioned(right: -14, top: 6, child: Icon(glyph, size: 96, color: Colors.white.withValues(alpha: 0.14))),
          // Bottom scrim for legible text
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)]),
              ),
            ),
          ),
          if (badge != null)
            Positioned(left: 12, top: 12, child: Pill(color: Colors.white24, child: Text(tr(badge!), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)))),
          Positioned(
            left: 12, right: 12, bottom: 12,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr(category), style: AppText.caption1.copyWith(color: Colors.white70)),
              const SizedBox(height: 2),
              Text(tr(title), maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.label2.copyWith(color: Colors.white)),
              const SizedBox(height: 2),
              Text(tr(subtitle), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: Colors.white70)),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Rounded search field used across the Points hub / Earn / Redeem screens
/// (a "Search for a store" pill).
class HubSearchField extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;
  const HubSearchField({super.key, required this.hint, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
        child: Row(children: [
          Icon(Icons.search_rounded, size: 20, color: AppColors.textLight),
          const SizedBox(width: 10),
          Text(tr(hint), style: AppText.body2.copyWith(color: AppColors.textLight)),
        ]),
      ),
    );
  }
}

/// Large sponsor promo card (a "20% OFF" partner-offer card) —
/// a coloured gradient tile with a sponsor avatar, category, a headline offer
/// and an info button. Always shown with an EMBA/S04 partner.
class SponsorPromoCard extends StatelessWidget {
  final String sponsor;
  final String category;
  final String offer;
  final String sub;
  final Color color;
  final VoidCallback? onTap;
  const SponsorPromoCard({
    super.key,
    required this.sponsor,
    required this.category,
    required this.offer,
    required this.sub,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        height: 170,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, Color.lerp(color, Colors.black, 0.35)!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              SponsorLogo(name: sponsor, size: 34, bg: Colors.white, fg: color, symbol: sponsorByName(sponsor)?.icon),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(sponsor, style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                Text(tr(category), style: AppText.caption1.copyWith(color: Colors.white70)),
              ])),
              const Icon(Icons.info_outline_rounded, size: 20, color: Colors.white70),
            ]),
            const Spacer(),
            Text(offer, style: AppText.h1.copyWith(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(tr(sub), style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ),
      ),
    );
  }
}

/// White list row used for Earn / Redeem category lists: circular icon,
/// title, subtitle (the "rate" line) and a chevron.
class HubListRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;
  const HubListRow({super.key, required this.icon, required this.title, required this.subtitle, this.iconColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = iconColor ?? AppColors.brandPrimary;
    return Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.tile),
          border: Border.all(color: AppColors.borderLightest),
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: c, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(title), style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15)),
            const SizedBox(height: 2),
            Text(tr(subtitle), style: AppText.body3Regular),
          ])),
          Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
        ]),
      ),
    );
  }
}
