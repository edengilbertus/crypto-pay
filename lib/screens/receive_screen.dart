import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/wallet/wallet_service.dart';
import '../theme/app_colors.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key, required this.walletService});

  final WalletService walletService;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final address = walletService.address ?? '';
    final chain = walletService.activeChain;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'Your address',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: 8),
          Text(
            chain.name,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          if (address.isEmpty)
            const Center(child: Text('Connect a wallet first'))
          else ...[
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: QrImageView(
                  data: address,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SelectableText(
              address,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: address));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Address copied')),
                  );
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy address'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.pink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Only send ${chain.name} (${chain.symbol}) assets to this address.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}
