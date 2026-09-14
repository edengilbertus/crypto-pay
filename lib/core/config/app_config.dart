/// App configuration for Crypto Pay.
///
/// Prefer passing secrets at build time:
/// ```
/// flutter build apk --release \
///   --dart-define=ALCHEMY_API_KEY=... \
///   --dart-define=REOWN_PROJECT_ID=... \
///   --dart-define=UNIVERSAL_LINK=https://your-domain.com
/// ```
/// Fallbacks below keep local debug/dev working for a single-user build.
abstract final class AppConfig {
  static const String reownProjectId = String.fromEnvironment(
    'REOWN_PROJECT_ID',
    defaultValue: '6e15f097074bba08cf99ce650ad88996',
  );

  static const String alchemyApiKey = String.fromEnvironment(
    'ALCHEMY_API_KEY',
    defaultValue: 'alch_fYlmJuZvd3Db5t_-lo2Mz',
  );

  /// MoonPay publishable key (pk_...) for fiat on-ramp.
  static const String moonPayApiKey = String.fromEnvironment(
    'MOONPAY_API_KEY',
    defaultValue: '',
  );

  static const String appName = 'Crypto Pay';
  static const String appDescription =
      'Send, receive, and manage crypto balances.';

  static const String nativeRedirect = 'cryptopay://';

  /// Replace with your real HTTPS domain for App Links / Universal Links.
  static const String universalLink = String.fromEnvironment(
    'UNIVERSAL_LINK',
    defaultValue: 'https://cryptopay.example',
  );

  static String get ethMainnetRpc =>
      'https://eth-mainnet.g.alchemy.com/v2/$alchemyApiKey';
  static String get bscMainnetRpc =>
      'https://bnb-mainnet.g.alchemy.com/v2/$alchemyApiKey';
  static String get polygonMainnetRpc =>
      'https://polygon-mainnet.g.alchemy.com/v2/$alchemyApiKey';
  static String get baseMainnetRpc =>
      'https://base-mainnet.g.alchemy.com/v2/$alchemyApiKey';

  /// USDC on Ethereum mainnet.
  static const String usdcEthAddress =
      '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
}
