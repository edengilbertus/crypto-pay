import 'package:flutter/material.dart';

import '../core/services/onramp_service.dart';
import '../core/wallet/wallet_service.dart';
import '../theme/app_colors.dart';

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key, required this.walletService});

  final WalletService walletService;

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final _amountController = TextEditingController(text: '50');
  final _onRamp = OnRampService();
  String _asset = 'ETH';
  bool _loading = false;
  String? _error;

  static const _amounts = [20, 50, 100, 250];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _buy() async {
    final address = widget.walletService.address;
    if (address == null) {
      setState(() => _error = 'Connect a wallet first');
      return;
    }
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _onRamp.openMoonPay(
        walletAddress: address,
        chain: widget.walletService.activeChain,
        assetSymbol: _asset,
        fiatAmount: amount,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Finish purchase in the browser / MoonPay app'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final wallet = widget.walletService;
    final connected = wallet.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy crypto'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'Pay with card or bank. Crypto is delivered to your connected wallet.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: 20),
          if (!connected)
            FilledButton.icon(
              onPressed: wallet.isReady ? wallet.openConnectModal : null,
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Connect wallet'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.pink),
            )
          else ...[
            Text(
              'Network · ${wallet.activeChain.name}',
              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Asset',
              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'ETH', label: Text('ETH')),
                ButtonSegment(value: 'USDC', label: Text('USDC')),
              ],
              selected: {_asset},
              onSelectionChanged: (s) => setState(() => _asset = s.first),
            ),
            const SizedBox(height: 16),
            Text(
              'You pay (USD)',
              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: r'$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final a in _amounts)
                  ChoiceChip(
                    label: Text('\$$a'),
                    selected: _amountController.text.trim() == '$a',
                    onSelected: (_) {
                      setState(() => _amountController.text = '$a');
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deliver to', style: textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(
                    wallet.address ?? '—',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: AppColors.red)),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: _loading ? null : _buy,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.credit_card),
              label: Text(_loading ? 'Opening…' : 'Continue to buy'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.pink,
                minimumSize: const Size.fromHeight(56),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Powered by MoonPay. KYC and fees are handled by the provider. Crypto Pay never sees your card.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}
