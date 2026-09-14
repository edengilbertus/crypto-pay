import 'package:url_launcher/url_launcher.dart';

import '../../models/models.dart';
import '../config/app_config.dart';

/// Fiat on-ramp via MoonPay hosted checkout (MVP).
/// Requires a MoonPay API key: --dart-define=MOONPAY_API_KEY=pk_...
class OnRampService {
  /// Opens MoonPay buy flow for [asset] on [chain] into [walletAddress].
  Future<void> openMoonPay({
    required String walletAddress,
    required ChainOption chain,
    required String assetSymbol,
    required double fiatAmount,
    String fiatCurrency = 'usd',
  }) async {
    final apiKey = AppConfig.moonPayApiKey;
    if (apiKey.isEmpty) {
      throw Exception(
        'Missing MOONPAY_API_KEY. Get one at moonpay.com and pass --dart-define=MOONPAY_API_KEY=...',
      );
    }

    final currency = _moonPayCurrency(assetSymbol, chain);
    final uri = Uri.parse('https://buy.moonpay.com').replace(
      queryParameters: {
        'apiKey': apiKey,
        'walletAddress': walletAddress,
        'currencyCode': currency,
        'baseCurrencyCode': fiatCurrency,
        'baseCurrencyAmount': fiatAmount.toStringAsFixed(2),
        'colorCode': '#F46FA8',
      },
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open MoonPay');
    }
  }

  String _moonPayCurrency(String asset, ChainOption chain) {
    // MoonPay uses chain-specific codes for some assets.
    if (asset == 'ETH') {
      if (chain.chainId == '1') return 'eth';
      if (chain.chainId == '8453') return 'eth_base';
      return 'eth';
    }
    if (asset == 'USDC') {
      if (chain.chainId == '1') return 'usdc';
      if (chain.chainId == '137') return 'usdc_polygon';
      if (chain.chainId == '8453') return 'usdc_base';
      return 'usdc';
    }
    if (asset == 'BNB' || chain.chainId == '56') return 'bnb';
    if (chain.chainId == '137') return 'pol_polygon';
    return asset.toLowerCase();
  }
}
