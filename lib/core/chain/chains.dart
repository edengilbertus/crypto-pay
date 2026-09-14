import '../../models/models.dart';
import '../config/app_config.dart';

/// Supported EVM networks (Alchemy-backed RPCs).
abstract final class Chains {
  static final ChainOption ethereum = ChainOption(
    chainId: '1',
    name: 'Ethereum',
    symbol: 'ETH',
    rpcUrl: AppConfig.ethMainnetRpc,
    caip2: 'eip155:1',
    explorerTxUrl: 'https://etherscan.io/tx/',
  );

  static final ChainOption bsc = ChainOption(
    chainId: '56',
    name: 'BNB Chain',
    symbol: 'BNB',
    rpcUrl: AppConfig.bscMainnetRpc,
    caip2: 'eip155:56',
    explorerTxUrl: 'https://bscscan.com/tx/',
  );

  static final ChainOption polygon = ChainOption(
    chainId: '137',
    name: 'Polygon',
    symbol: 'POL',
    rpcUrl: AppConfig.polygonMainnetRpc,
    caip2: 'eip155:137',
    explorerTxUrl: 'https://polygonscan.com/tx/',
  );

  static final ChainOption base = ChainOption(
    chainId: '8453',
    name: 'Base',
    symbol: 'ETH',
    rpcUrl: AppConfig.baseMainnetRpc,
    caip2: 'eip155:8453',
    explorerTxUrl: 'https://basescan.org/tx/',
  );

  static final List<ChainOption> all = [ethereum, bsc, polygon, base];

  static ChainOption? byId(String? id) {
    if (id == null) return null;
    for (final c in all) {
      if (c.chainId == id || c.caip2 == id) return c;
    }
    return null;
  }
}
