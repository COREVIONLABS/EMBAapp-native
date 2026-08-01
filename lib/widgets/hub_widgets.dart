import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

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
    return GestureDetector(
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
    return GestureDetector(
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

/// Rounded search field used across the Points hub / Earn / Redeem screens
/// (mirrors Revolut's "Search for a store" pill).
class HubSearchField extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;
  const HubSearchField({super.key, required this.hint, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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

/// Large sponsor promo card (mirrors Revolut's Dell/Macy's "20% OFF" cards) —
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
    return GestureDetector(
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
