import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/chain/chains.dart';
import '../core/wallet/wallet_service.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key, required this.walletService});

  final WalletService walletService;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final items = walletService.activity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No transactions yet.\nSends will show up here.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tx = items[index];
                return _TxTile(tx: tx);
              },
            ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.tx});

  final TxRecord tx;

  Color get _statusColor {
    switch (tx.status) {
      case TxStatus.confirmed:
        return AppColors.green;
      case TxStatus.failed:
        return AppColors.red;
      case TxStatus.pending:
        return AppColors.blueDeep;
    }
  }

  String get _statusLabel {
    switch (tx.status) {
      case TxStatus.confirmed:
        return 'Confirmed';
      case TxStatus.failed:
        return 'Failed';
      case TxStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final chain = Chains.byId(tx.chainId);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: chain == null
            ? null
            : () async {
                final uri = Uri.parse(chain.txUrl(tx.hash));
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.north_east, color: _statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.amountLabel,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'To ${tx.shortTo} · ${tx.shortHash}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _statusLabel,
                    style: textTheme.labelMedium?.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    chain?.name ?? '',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
