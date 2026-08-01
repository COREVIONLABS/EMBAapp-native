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

/// App-wide tap feedback: a subtle press-scale on any tappable content whose
/// custom decoration would otherwise swallow an InkWell ripple (cards, gradient
/// tiles, image cards). When [onTap] is null the child is returned untouched, so
/// it stays inert with no phantom press animation.
class Tappable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final HitTestBehavior behavior;
  const Tappable({super.key, required this.child, this.onTap, this.scale = 0.97, this.behavior = HitTestBehavior.opaque});

  @override
  State<Tappable> createState() => _TappableState();
}

class _TappableState extends State<Tappable> {
  bool _down = false;
  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
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
          side: BorderSide(color: AppColors.borderLightest, width: 1.5),
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
  final Color? color;
  final double radius;
  final Border? border;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
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
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: AppColors.borderLightest),
        boxShadow: shadow,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Tappable(onTap: onTap, scale: 0.98, child: card);
  }
}

/// Small rounded pill/badge.
class Pill extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  const Pill({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.brandLightest) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: child,
    );
  }
}

/// Section header "Title ... See All >".
/// App-wide section header: a bold title (label1) with an optional trailing
/// action link ("See All" + chevron). Pass `action: null` for a title-only
/// header. The trailing link only renders when [onAction] is provided, so
/// there are never dead links.
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
        Expanded(child: Text(tr(title), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.label1)),
        if (action != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(tr(action!), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.brandPrimary),
              ],
            ),
          ),
      ],
    );
  }
}
