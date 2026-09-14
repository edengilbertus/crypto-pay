import 'package:flutter/material.dart';

/// Soft brush-stroke card using a generated texture asset when available,
/// falling back to a painter if the asset fails to load.
class BrushCard extends StatelessWidget {
  const BrushCard({
    super.key,
    required this.child,
    required this.baseColor,
    this.textureAsset = 'assets/brush_pink.png',
    this.radius = 28,
    this.padding = const EdgeInsets.all(22),
    this.height,
    this.fit = BoxFit.cover,
  });

  final Widget child;
  final Color baseColor;
  final String textureAsset;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.55,
              child: Image.asset(
                textureAsset,
                fit: fit,
                colorBlendMode: BlendMode.softLight,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
