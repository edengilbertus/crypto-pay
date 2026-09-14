import 'dart:convert';

import 'package:http/http.dart' as http;

/// Free CoinGecko simple-price client (no key).
class PriceService {
  Future<Map<String, double>> fetchUsdPrices() async {
    final uri = Uri.parse(
      'https://api.coingecko.com/api/v3/simple/price'
      '?ids=ethereum,bitcoin,usd-coin,binancecoin,polygon-ecosystem-token'
      '&vs_currencies=usd',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw Exception('Price API ${res.statusCode}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    double pick(String id) {
      final node = json[id];
      if (node is Map && node['usd'] is num) {
        return (node['usd'] as num).toDouble();
      }
      return 0;
    }

    return {
      'ETH': pick('ethereum'),
      'BTC': pick('bitcoin'),
      'USDC': pick('usd-coin'),
      'BNB': pick('binancecoin'),
      'POL': pick('polygon-ecosystem-token'),
    };
  }
}
