import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CryptoAsset {
  const CryptoAsset({
    required this.symbol,
    required this.name,
    required this.amount,
    required this.price,
    required this.changePct,
    required this.tint,
  });

  final String symbol;
  final String name;
  final String amount;
  final String price;
  final double changePct;
  final Color tint;

  bool get isUp => changePct >= 0;
}

class AppData {
  static const List<CryptoAsset> assets = [
    CryptoAsset(
      symbol: 'ETH',
      name: 'Ethereum',
      amount: '—',
      price: r'$0',
      changePct: 0,
      tint: AppColors.blueSoft,
    ),
    CryptoAsset(
      symbol: 'USDC',
      name: 'USD Coin',
      amount: '—',
      price: r'$0',
      changePct: 0,
      tint: AppColors.pinkSoft,
    ),
  ];

  static const List<double> btcBars = [
    0.42, 0.55, 0.48, 0.62, 0.58, 0.71, 0.66, 0.78,
    0.70, 0.84, 0.76, 0.88, 0.81, 0.93, 0.86, 0.97,
    0.90, 1.00,
  ];
}

class ChainOption {
  const ChainOption({
    required this.chainId,
    required this.name,
    required this.symbol,
    required this.rpcUrl,
    required this.caip2,
    required this.explorerTxUrl,
  });

  final String chainId;
  final String name;
  final String symbol;
  final String rpcUrl;
  final String caip2;
  final String explorerTxUrl;

  String txUrl(String hash) => '$explorerTxUrl$hash';
}

enum TxStatus { pending, confirmed, failed }

class TxRecord {
  TxRecord({
    required this.hash,
    required this.to,
    required this.amountLabel,
    required this.chainId,
    required this.createdAt,
    this.status = TxStatus.pending,
  });

  final String hash;
  final String to;
  final String amountLabel;
  final String chainId;
  final DateTime createdAt;
  TxStatus status;

  String get shortHash {
    if (hash.length < 12) return hash;
    return '${hash.substring(0, 8)}…${hash.substring(hash.length - 6)}';
  }

  String get shortTo {
    if (to.length < 12) return to;
    return '${to.substring(0, 6)}…${to.substring(to.length - 4)}';
  }
}

class WalletException implements Exception {
  WalletException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}

class SendPreview {
  const SendPreview({
    required this.from,
    required this.to,
    required this.amountNative,
    required this.valueWeiHex,
    required this.gasLimit,
    required this.gasPriceWei,
    required this.feeNative,
    required this.chain,
  });

  final String from;
  final String to;
  final double amountNative;
  final String valueWeiHex;
  final BigInt gasLimit;
  final BigInt gasPriceWei;
  final double feeNative;
  final ChainOption chain;
}
