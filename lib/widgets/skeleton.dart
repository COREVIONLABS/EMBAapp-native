import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated shimmer sweep used behind skeleton placeholders. Wrap any subtree
/// of [SkeletonBox]es; the moving highlight makes them read as "loading".
class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});
  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppColors.surfaceMinimal;
    final hi = Color.lerp(base, AppColors.surface, 0.6)!;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = (bounds.width + bounds.width) * _c.value - bounds.width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, hi, base],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideGradient(dx),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double dx;
  const _SlideGradient(this.dx);
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) => Matrix4.translationValues(dx, 0, 0);
}

/// A single rounded grey placeholder block.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 8, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

/// Circular placeholder (avatars, action circles).
class SkeletonCircle extends StatelessWidget {
  final double size;
  const SkeletonCircle({super.key, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: AppColors.surfaceMinimal, shape: BoxShape.circle));
  }
}

/// Generic hub skeleton (balance card → action circles → section list). Shown
/// briefly on first load of the Points / Membership / Profile tabs.
class HubSkeleton extends StatelessWidget {
  const HubSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          const SkeletonBox(width: 150, height: 22, radius: 8),
          const SizedBox(height: 20),
          const SkeletonBox(height: 130, radius: 22),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            for (var i = 0; i < 4; i++)
              const Column(children: [SkeletonCircle(size: 56), SizedBox(height: 8), SkeletonBox(width: 44, height: 10)]),
          ]),
          const SizedBox(height: 26),
          const SkeletonBox(width: 130, height: 18),
          const SizedBox(height: 14),
          for (var i = 0; i < 4; i++) ...[
            Row(children: [
              const SkeletonCircle(size: 46),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                SkeletonBox(width: 160, height: 13),
                SizedBox(height: 7),
                SkeletonBox(width: 100, height: 11),
              ]),
            ]),
            const SizedBox(height: 18),
          ],
        ]),
      ),
    );
  }
}
