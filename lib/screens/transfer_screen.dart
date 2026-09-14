import 'package:flutter/material.dart';

import '../core/wallet/wallet_service.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, required this.walletService});

  final WalletService walletService;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _toController = TextEditingController();
  final _amountController = TextEditingController(text: '0.01');
  SendPreview? _preview;
  bool _previewing = false;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.walletService.addListener(_onWallet);
  }

  @override
  void dispose() {
    widget.walletService.removeListener(_onWallet);
    _toController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onWallet() {
    if (mounted) setState(() {});
  }

  Future<void> _estimate() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    setState(() {
      _previewing = true;
      _error = null;
      _preview = null;
    });
    try {
      final preview = await widget.walletService.previewSend(
        to: _toController.text.trim(),
        amountNative: amount,
      );
      if (!mounted) return;
      setState(() => _preview = preview);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _previewing = false);
    }
  }

  Future<void> _send() async {
    final preview = _preview;
    if (preview == null) {
      await _estimate();
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final hash = await widget.walletService.sendNative(preview);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sent · $hash')),
      );
      setState(() {
        _preview = null;
        _amountController.text = '0.01';
        _toController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final wallet = widget.walletService;
    final connected = wallet.isConnected;
    final chain = wallet.activeChain;
    final preview = _preview;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(
            'Send',
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            connected
                ? 'From your wallet on ${chain.name}'
                : 'Connect a wallet to send',
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
            _FieldLabel('Recipient address'),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                hintText: '0x…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ),
              onChanged: (_) => setState(() => _preview = null),
            ),
            const SizedBox(height: 16),
            _FieldLabel('Amount (${chain.symbol})'),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '0.01',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ),
              onChanged: (_) => setState(() => _preview = null),
            ),
            const SizedBox(height: 8),
            Text(
              'Balance: ${wallet.nativeBalance?.toStringAsFixed(6) ?? '—'} ${chain.symbol}'
              '${wallet.nativeUsd != null ? '  ·  ≈ \$${wallet.nativeUsd!.toStringAsFixed(2)}' : ''}',
              style: textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: textTheme.bodySmall?.copyWith(color: AppColors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (preview != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    _row('Network', preview.chain.name),
                    _row('Amount',
                        '${preview.amountNative} ${preview.chain.symbol}'),
                    _row('Gas limit', preview.gasLimit.toString()),
                    _row(
                      'Est. fee',
                      '${preview.feeNative.toStringAsFixed(8)} ${preview.chain.symbol}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previewing || _sending ? null : _estimate,
                    child: _previewing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Estimate gas'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _sending ? null : _send,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.pink,
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Send'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your wallet will ask you to confirm. Keys never leave the wallet app.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.inkMuted)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
