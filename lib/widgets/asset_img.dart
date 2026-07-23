import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Loads a real exported illustration from `assets/images/{name}.png`.
/// If the file isn't bundled yet, shows a subtle branded fallback so the
/// layout stays intact (real assets are dropped in during the Figma pass).
class AssetImg extends StatelessWidget {
  final String name;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  const AssetImg(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallbackIcon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/$name.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stack) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.pointsGradient),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(fallbackIcon, color: Colors.white70, size: (width ?? 40) * 0.5),
    );
  }
}
