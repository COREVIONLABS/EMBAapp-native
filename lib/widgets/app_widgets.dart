import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';

/// Local SVG asset helper.
class Svg extends StatelessWidget {
  final String name;
  final double? size;
  final double? width;
  final double? height;
  final Color? color;
  const Svg(this.name, {super.key, this.size, this.width, this.height, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: width ?? size,
      height: height ?? size,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}

/// Primary filled pill button (Schalke blue).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color color;
  final Color textColor;
  final double height;
  const PrimaryButton(this.label,
      {super.key,
      this.onTap,
      this.trailing,
      this.color = AppColors.brandPrimary,
      this.textColor = AppColors.white,
      this.height = 54});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: AppText.label2.copyWith(color: textColor, fontWeight: FontWeight.w700)),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary / outlined pill button.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  const SecondaryButton(this.label, {super.key, this.onTap, this.height = 54});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.borderLightest, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
          foregroundColor: AppColors.textDarker,
        ),
        child: Text(label, style: AppText.label2.copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// Rounded card container with the design's default surface + border.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final Border? border;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.radius = AppRadii.tile,
    this.border,
    this.shadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: AppColors.borderLightest),
        boxShadow: shadow,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}

/// Small rounded pill/badge.
class Pill extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  const Pill({
    super.key,
    required this.child,
    this.color = AppColors.brandLightest,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: child,
    );
  }
}

/// Section header "Title ... See All >".
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.action = 'See All', this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.label2.copyWith(color: AppColors.textDarker)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(tr(action!), style: AppText.body3.copyWith(color: AppColors.brandPrimary)),
                const SizedBox(width: 4),
                const Svg('arrow_right', size: 16),
              ],
            ),
          ),
      ],
    );
  }
}
