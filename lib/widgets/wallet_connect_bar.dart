import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class WalletConnectBar extends StatelessWidget {
  const WalletConnectBar({
    super.key,
    required this.isReady,
    required this.isConnected,
    required this.address,
    required this.chainName,
    required this.onConnect,
    required this.onDisconnect,
  });

  final bool isReady;
  final bool isConnected;
  final String? address;
  final String? chainName;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  String get _shortAddress {
    final a = address;
    if (a == null || a.length < 12) return a ?? '';
    return '${a.substring(0, 6)}…${a.substring(a.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    if (isConnected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.bluePale,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 18,
                color: AppColors.blueDeep,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _shortAddress,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    chainName ?? 'Connected',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onDisconnect,
              child: const Text('Disconnect'),
            ),
          ],
        ),
      );
    }

    return FilledButton.icon(
      onPressed: isReady ? onConnect : null,
      icon: isReady
          ? const Icon(Icons.account_balance_wallet_outlined)
          : const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
      label: Text(isReady ? 'Connect wallet' : 'Starting wallet…'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.pink,
        minimumSize: const Size.fromHeight(52),
      ),
    );
  }
}
