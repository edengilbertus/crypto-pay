import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';

class AssetCircle extends StatelessWidget {
  const AssetCircle({
    super.key,
    required this.asset,
    this.size = 56,
  });

  final CryptoAsset asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: asset.tint,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        asset.symbol.substring(0, 1),
        style: TextStyle(
          color: AppColors.ink.withValues(alpha: 0.75),
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

class PortfolioTile extends StatelessWidget {
  const PortfolioTile({
    super.key,
    required this.asset,
    required this.onTap,
  });

  final CryptoAsset asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final changeColor = asset.isUp ? AppColors.green : AppColors.red;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AssetCircle(asset: asset, size: 46),
                  const Spacer(),
                  Text(
                    '${asset.changePct >= 0 ? '+' : ''}${asset.changePct.toStringAsFixed(2)}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                asset.symbol,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                asset.price,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickActionChip extends StatelessWidget {
  const QuickActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: selected ? AppColors.pink : AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : AppColors.ink,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
