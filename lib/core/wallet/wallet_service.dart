import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reown_appkit/reown_appkit.dart';

import '../chain/chains.dart';
import '../config/app_config.dart';
import '../../models/models.dart';
import '../services/price_service.dart';

/// Reown AppKit (WalletConnect v2) + Alchemy reads/writes.
class WalletService extends ChangeNotifier {
  WalletService({PriceService? priceService})
      : _priceService = priceService ?? PriceService();

  final PriceService _priceService;

  ReownAppKitModal? _modal;
  bool _ready = false;

  double? _nativeBalance;
  double? _usdcBalance;
  bool _balanceLoading = false;
  String? _balanceError;

  Map<String, double> _prices = {};
  bool _pricesLoading = false;

  final List<TxRecord> _activity = [];
  final Map<String, Timer> _watchers = {};

  bool get isReady => _ready;
  ReownAppKitModal? get modal => _modal;
  bool get isConnected => _modal?.isConnected ?? false;

  double? get nativeBalance => _nativeBalance;
  double? get usdcBalance => _usdcBalance;
  bool get balanceLoading => _balanceLoading;
  String? get balanceError => _balanceError;
  Map<String, double> get prices => _prices;
  bool get pricesLoading => _pricesLoading;
  List<TxRecord> get activity => List.unmodifiable(_activity);

  String? get address {
    final modal = _modal;
    if (modal == null || !modal.isConnected) return null;
    return modal.session?.getAddress(NetworkUtils.eip155);
  }

  String? get chainName => _modal?.selectedChain?.name;
  String? get chainId => _modal?.selectedChain?.chainId;

  ChainOption get activeChain =>
      Chains.byId(chainId) ?? Chains.ethereum;

  String get nativeSymbol => activeChain.symbol;

  double? get nativeUsd {
    final bal = _nativeBalance;
    final px = _prices[nativeSymbol] ?? _prices['ETH'];
    if (bal == null || px == null) return null;
    return bal * px;
  }

  Future<void> init(BuildContext context) async {
    if (_ready) return;

    for (final chain in Chains.all) {
      if (chain.chainId == '8453') {
        ReownAppKitModalNetworks.addSupportedNetworks('eip155', [
          ReownAppKitModalNetworkInfo(
            name: chain.name,
            chainId: chain.chainId,
            currency: chain.symbol,
            rpcUrl: chain.rpcUrl,
            explorerUrl: chain.explorerTxUrl.replaceAll('/tx/', ''),
          ),
        ]);
      }
    }

    _modal = ReownAppKitModal(
      context: context,
      projectId: AppConfig.reownProjectId,
      logLevel: kDebugMode ? LogLevel.all : LogLevel.nothing,
      disconnectOnDispose: false,
      metadata: PairingMetadata(
        name: AppConfig.appName,
        description: AppConfig.appDescription,
        url: AppConfig.universalLink,
        icons: [
          'https://raw.githubusercontent.com/reown-com/reown_flutter/refs/heads/develop/assets/appkit_logo.png',
        ],
        redirect: Redirect(
          native: AppConfig.nativeRedirect,
          universal: AppConfig.universalLink,
          linkMode: true,
        ),
      ),
      featuredWalletIds: {
        'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96',
        'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa',
        '1ae92b26df02f0abca6304df07debccd18262fdf5fe82daa81593582dac9a369',
      },
      enableAnalytics: false,
    );

    await _modal!.init();
    _modal!.addListener(_onModalChanged);
    _ready = true;
    unawaited(loadPrices());
    if (isConnected) unawaited(refreshBalances());
    notifyListeners();
  }

  void _onModalChanged() {
    notifyListeners();
    if (isConnected) {
      unawaited(refreshBalances());
    } else {
      _nativeBalance = null;
      _usdcBalance = null;
      _balanceError = null;
      notifyListeners();
    }
  }

  Web3Client _client([String? rpc]) =>
      Web3Client(rpc ?? activeChain.rpcUrl, http.Client());

  Future<void> loadPrices() async {
    _pricesLoading = true;
    notifyListeners();
    try {
      _prices = await _priceService.fetchUsdPrices();
    } catch (e) {
      if (kDebugMode) debugPrint('Price error: $e');
    } finally {
      _pricesLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBalances() async {
    final addr = address;
    if (addr == null) return;
    _balanceLoading = true;
    _balanceError = null;
    notifyListeners();
    final client = _client();
    try {
      final eth = await client.getBalance(EthereumAddress.fromHex(addr));
      _nativeBalance = eth.getValueInUnit(EtherUnit.ether);

      if (activeChain.chainId == '1') {
        _usdcBalance = await _readErc20(
          client,
          token: AppConfig.usdcEthAddress,
          owner: addr,
          decimals: 6,
        );
      } else {
        _usdcBalance = null;
      }
    } catch (e) {
      _balanceError = 'Could not load balance';
      if (kDebugMode) debugPrint('Balance error: $e');
    } finally {
      client.dispose();
      _balanceLoading = false;
      notifyListeners();
    }
  }

  Future<double?> _readErc20(
    Web3Client client, {
    required String token,
    required String owner,
    required int decimals,
  }) async {
    final abi = ContractAbi.fromJson(
      '[{"inputs":[{"name":"owner","type":"address"}],"name":"balanceOf",'
      '"outputs":[{"name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]',
      'ERC20',
    );
    final contract = DeployedContract(abi, EthereumAddress.fromHex(token));
    final fn = contract.function('balanceOf');
    final result = await client.call(
      contract: contract,
      function: fn,
      params: [EthereumAddress.fromHex(owner)],
    );
    if (result.isEmpty) return null;
    final raw = result.first;
    if (raw is BigInt) {
      return raw.toDouble() / BigInt.from(10).pow(decimals).toDouble();
    }
    return null;
  }

  Future<void> switchToChain(ChainOption chain) async {
    final modal = _modal;
    if (modal == null || !modal.isConnected) return;
    final info = ReownAppKitModalNetworkInfo(
      name: chain.name,
      chainId: chain.chainId,
      currency: chain.symbol,
      rpcUrl: chain.rpcUrl,
      explorerUrl: chain.explorerTxUrl.replaceAll('/tx/', ''),
    );
    try {
      await modal.requestSwitchToChain(info);
      await refreshBalances();
    } catch (e) {
      throw WalletException(_mapRpcError(e));
    }
  }

  Future<SendPreview> previewSend({
    required String to,
    required double amountNative,
  }) async {
    final from = address;
    if (from == null) {
      throw WalletException('Connect a wallet first');
    }
    if (!_isValidAddress(to)) {
      throw WalletException('Invalid recipient address');
    }
    if (amountNative <= 0) {
      throw WalletException('Amount must be greater than zero');
    }

    final chain = activeChain;
    final client = _client(chain.rpcUrl);
    try {
      final fromAddr = EthereumAddress.fromHex(from);
      final toAddr = EthereumAddress.fromHex(to);
      final value = BigInt.from((amountNative * 1e18).round());
      final gasPrice = await client.getGasPrice();
      BigInt gasLimit;
      try {
        gasLimit = await client.estimateGas(
          sender: fromAddr,
          to: toAddr,
          value: EtherAmount.inWei(value),
        );
        // buffer
        gasLimit = gasLimit * BigInt.from(12) ~/ BigInt.from(10);
      } catch (_) {
        gasLimit = BigInt.from(21000);
      }
      final feeWei = gasLimit * gasPrice.getInWei;
      return SendPreview(
        from: from,
        to: to,
        amountNative: amountNative,
        valueWeiHex: '0x${value.toRadixString(16)}',
        gasLimit: gasLimit,
        gasPriceWei: gasPrice.getInWei,
        feeNative: feeWei.toDouble() / BigInt.from(10).pow(18).toDouble(),
        chain: chain,
      );
    } finally {
      client.dispose();
    }
  }

  /// Sends native token via wallet signature. Returns tx hash.
  Future<String> sendNative(SendPreview preview) async {
    final modal = _modal;
    final session = modal?.session;
    if (modal == null || session == null || !isConnected) {
      throw WalletException('Wallet not connected');
    }

    final chainIdCaip = preview.chain.caip2;
    try {
      final result = await modal.request(
        topic: session.topic,
        chainId: chainIdCaip,
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': preview.from,
              'to': preview.to,
              'value': preview.valueWeiHex,
              'gas': '0x${preview.gasLimit.toRadixString(16)}',
            },
          ],
        ),
      );

      final hash = _extractTxHash(result);
      if (hash == null) {
        throw WalletException('Wallet did not return a transaction hash');
      }

      final record = TxRecord(
        hash: hash,
        to: preview.to,
        amountLabel:
            '${preview.amountNative.toStringAsFixed(6)} ${preview.chain.symbol}',
        chainId: preview.chain.chainId,
        createdAt: DateTime.now(),
      );
      _activity.insert(0, record);
      notifyListeners();
      unawaited(_watchTx(record));
      unawaited(refreshBalances());
      return hash;
    } catch (e) {
      throw WalletException(_mapRpcError(e));
    }
  }

  String? _extractTxHash(dynamic result) {
    if (result is String && result.startsWith('0x')) return result;
    if (result is Map) {
      final h = result['result'] ?? result['hash'];
      if (h is String) return h;
    }
    return null;
  }

  Future<void> _watchTx(TxRecord record) async {
    final client = _client(Chains.byId(record.chainId)?.rpcUrl);
    const maxAttempts = 40;
    for (var i = 0; i < maxAttempts; i++) {
      await Future<void>.delayed(const Duration(seconds: 4));
      try {
        final receipt = await client.getTransactionReceipt(record.hash);
        if (receipt != null) {
          final status = receipt.status;
          final ok = status == true;
          record.status = ok ? TxStatus.confirmed : TxStatus.failed;
          notifyListeners();
          client.dispose();
          return;
        }
      } catch (_) {}
    }
    client.dispose();
  }

  Future<void> openConnectModal() async {
    await _modal?.openModalView();
  }

  Future<void> openNetworkModal() async {
    await _modal?.openModalView();
  }

  Future<void> disconnect() async {
    await _modal?.disconnect();
    _nativeBalance = null;
    _usdcBalance = null;
    notifyListeners();
  }

  bool _isValidAddress(String value) {
    final v = value.trim();
    if (!v.startsWith('0x') || v.length != 42) return false;
    return RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(v);
  }

  String _mapRpcError(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('user rejected') || s.contains('rejected')) {
      return 'Request rejected in wallet';
    }
    if (s.contains('insufficient')) {
      return 'Insufficient balance for amount + gas';
    }
    if (s.contains('chain') && s.contains('switch')) {
      return 'Could not switch network in wallet';
    }
    if (s.contains('timeout')) {
      return 'Request timed out — try again';
    }
    final raw = e.toString();
    return raw.length > 160 ? raw.substring(0, 160) : raw;
  }

  @override
  void dispose() {
    for (final t in _watchers.values) {
      t.cancel();
    }
    _modal?.removeListener(_onModalChanged);
    super.dispose();
  }
}
