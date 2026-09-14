import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/chain/chains.dart';
import '../core/wallet/wallet_service.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/asset_tiles.dart';
import '../widgets/brush_texture.dart';
import 'activity_screen.dart';
import 'buy_screen.dart';
import 'receive_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onNavigate,
    required this.walletService,
  });

  final ValueChanged<int> onNavigate;
  final WalletService walletService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.walletService.addListener(_onWalletChanged);
  }

  @override
  void dispose() {
    widget.walletService.removeListener(_onWalletChanged);
    super.dispose();
  }

  void _onWalletChanged() {
    if (mounted) setState(() {});
  }

  String get _shortAddress {
    final a = widget.walletService.address;
    if (a == null || a.length < 12) return a ?? '—';
    return '${a.substring(0, 6)}…${a.substring(a.length - 4)}';
  }

  String get _balanceDisplay {
    final w = widget.walletService;
    if (w.balanceLoading) return '…';
    final b = w.nativeBalance;
    if (b == null) return '—';
    return '${b.toStringAsFixed(4)} ${w.nativeSymbol}';
  }

  Future<void> _copyAddress() async {
    final a = widget.walletService.address;
    if (a == null) return;
    await Clipboard.setData(ClipboardData(text: a));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address copied')),
    );
  }

  Future<void> _pickNetwork() async {
    final wallet = widget.walletService;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                'Network',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (final chain in Chains.all)
                ListTile(
                  title: Text(chain.name),
                  subtitle: Text(chain.symbol),
                  trailing: wallet.chainId == chain.chainId
                      ? const Icon(Icons.check, color: AppColors.pinkDeep)
                      : null,
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(context).pop();
                    try {
                      await wallet.switchToChain(chain);
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final wallet = widget.walletService;
    final connected = wallet.isConnected;
    final ethUsd = wallet.prices['ETH'];
    final usdcBal = wallet.usdcBalance;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: AppColors.pinkPale,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_2_outlined,
                  color: AppColors.pinkDeep,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connected ? 'Wallet' : 'Crypto Pay',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      connected
                          ? '${wallet.chainName ?? 'Network'} · $_shortAddress'
                          : 'Connect to get started',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (connected) ...[
                _CircleIconButton(icon: Icons.copy, onTap: _copyAddress),
                const SizedBox(width: 10),
                _CircleIconButton(
                  icon: Icons.link_off,
                  onTap: () => wallet.disconnect(),
                ),
              ] else
                _CircleIconButton(
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: () => wallet.openConnectModal(),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (connected)
            Align(
              alignment: Alignment.centerLeft,
              child: ActionChip(
                avatar: const Icon(Icons.hub_outlined, size: 18),
                label: Text(wallet.activeChain.name),
                onPressed: _pickNetwork,
                backgroundColor: AppColors.surface,
              ),
            ),
          const SizedBox(height: 14),
          _HeroCard(
            connected: connected,
            balanceLabel: _balanceDisplay,
            usdLabel: wallet.nativeUsd != null
                ? '≈ \$${wallet.nativeUsd!.toStringAsFixed(2)}'
                : (ethUsd != null && wallet.nativeBalance != null
                    ? 'ETH \$${ethUsd.toStringAsFixed(0)}'
                    : 'Self-custody · keys stay with you'),
          ),
          const SizedBox(height: 20),
          if (!connected)
            FilledButton.icon(
              onPressed: wallet.isReady ? wallet.openConnectModal : null,
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: Text(wallet.isReady ? 'Connect wallet' : 'Starting…'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.pink,
                minimumSize: const Size.fromHeight(56),
              ),
            )
          else ...[
            Row(
              children: [
                _ActionBtn(
                  icon: Icons.north_east,
                  label: 'Send',
                  onTap: () => widget.onNavigate(1),
                ),
                const SizedBox(width: 10),
                _ActionBtn(
                  icon: Icons.qr_code,
                  label: 'Receive',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReceiveScreen(
                          walletService: wallet,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _ActionBtn(
                  icon: Icons.credit_card,
                  label: 'Buy',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BuyScreen(walletService: wallet),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _ActionBtn(
                  icon: Icons.receipt_long_outlined,
                  label: 'Activity',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ActivityScreen(
                          walletService: wallet,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),
          ],
          Text(
            connected ? 'Assets' : 'Popular assets',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (!connected)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 36,
                    color: AppColors.inkMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No wallet connected',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connect MetaMask, Trust, Coinbase, or another WalletConnect wallet to see balances and send crypto.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                _AssetRow(
                  symbol: wallet.nativeSymbol,
                  name: wallet.activeChain.name,
                  amount: wallet.balanceLoading
                      ? '…'
                      : '${wallet.nativeBalance?.toStringAsFixed(6) ?? '0'} ${wallet.nativeSymbol}',
                  usd: wallet.nativeUsd != null
                      ? '\$${wallet.nativeUsd!.toStringAsFixed(2)}'
                      : (ethUsd != null && wallet.nativeBalance != null
                          ? '\$${(wallet.nativeBalance! * ethUsd).toStringAsFixed(2)}'
                          : '—'),
                ),
                const SizedBox(height: 10),
                _AssetRow(
                  symbol: 'USDC',
                  name: 'USD Coin',
                  amount: wallet.activeChain.chainId == '1'
                      ? (usdcBal?.toStringAsFixed(2) ?? '0')
                      : 'Ethereum only',
                  usd: wallet.activeChain.chainId == '1'
                      ? '\$${(usdcBal ?? 0).toStringAsFixed(2)}'
                      : '—',
                ),
                if (wallet.balanceError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    wallet.balanceError!,
                    style: textTheme.bodySmall?.copyWith(color: AppColors.red),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.connected,
    required this.balanceLabel,
    required this.usdLabel,
  });

  final bool connected;
  final String balanceLabel;
  final String usdLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BrushCard(
      baseColor: connected ? AppColors.pink : AppColors.blueDeep,
      height: 172,
      radius: 30,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            connected ? 'Total balance' : 'Self-custody wallet',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            balanceLabel,
            style: textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            usdLabel,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: AppColors.ink),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({
    required this.symbol,
    required this.name,
    required this.amount,
    required this.usd,
  });

  final String symbol;
  final String name;
  final String amount;
  final String usd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AssetCircle(
              asset: CryptoAsset(
                symbol: symbol,
                name: name,
                amount: amount,
                price: usd,
                changePct: 0,
                tint: AppColors.blueSoft,
              ),
              size: 46,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: textTheme.titleMedium),
                  Text(amount, style: textTheme.bodySmall),
                ],
              ),
            ),
            Text(
              usd,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

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
          width: 48,
          height: 48,
          child: Icon(icon, color: AppColors.ink, size: 20),
        ),
      ),
    );
  }
}
