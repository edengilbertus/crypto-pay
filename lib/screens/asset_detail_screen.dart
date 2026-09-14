import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/asset_tiles.dart';
import '../widgets/price_chart.dart';

class AssetDetailScreen extends StatefulWidget {
  const AssetDetailScreen({super.key, required this.asset});

  final CryptoAsset asset;

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  String _range = 'Month';
  int _side = 0;

  static const _ranges = ['Day', 'Week', 'Month', 'Year', 'All'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final asset = widget.asset;
    final changeColor = asset.isUp ? AppColors.green : AppColors.red;

    return Scaffold(
      appBar: AppBar(
        leading: const _RoundBackButton(),
        title: Text(asset.symbol),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _RoundActionButton(
              icon: Icons.candlestick_chart_outlined,
              onTap: () {},
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Center(child: AssetCircle(asset: asset, size: 92)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              asset.symbol,
              style: textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              asset.price,
              style: textTheme.displayMedium,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${asset.changePct >= 0 ? '+' : ''}${asset.changePct.toStringAsFixed(2)}',
              style: textTheme.titleMedium?.copyWith(
                color: changeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const PriceBarChart(values: AppData.btcBars),
              Positioned(
                right: -2,
                top: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    asset.price,
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RangeTabs(
            options: _ranges,
            selected: _range,
            onChanged: (value) => setState(() => _range = value),
          ),
          const SizedBox(height: 20),
          _ExchangePairCard(asset: asset),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _SideButton(
                  label: 'Buy',
                  selected: _side == 0,
                  color: AppColors.blueDeep,
                  onTap: () => setState(() => _side = 0),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SideButton(
                  label: 'Sell',
                  selected: _side == 1,
                  color: AppColors.pink,
                  onTap: () => setState(() => _side = 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExchangePairCard extends StatelessWidget {
  const _ExchangePairCard({required this.asset});

  final CryptoAsset asset;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final eth = AppData.assets[1];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          AssetCircle(asset: eth, size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ETH',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  r'$2,112',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const Icon(Icons.swap_horiz, color: AppColors.inkMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'BNN',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  r'$880,0',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: selected ? color : color.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: _RoundActionButton(
        icon: Icons.chevron_left,
        onTap: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: AppColors.ink, size: 22),
        ),
      ),
    );
  }
}
