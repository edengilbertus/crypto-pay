import 'package:flutter/material.dart';

import 'core/wallet/wallet_service.dart';
import 'screens/home_screen.dart';
import 'screens/transfer_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CryptoPayApp());
}

class CryptoPayApp extends StatefulWidget {
  const CryptoPayApp({super.key});

  @override
  State<CryptoPayApp> createState() => _CryptoPayAppState();
}

class _CryptoPayAppState extends State<CryptoPayApp> {
  final WalletService walletService = WalletService();

  @override
  void dispose() {
    walletService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Pay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: RootShell(walletService: walletService),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.walletService});

  final WalletService walletService;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWallet();
    });
  }

  Future<void> _initWallet() async {
    if (!mounted) return;
    try {
      await widget.walletService.init(context);
    } catch (e) {
      debugPrint('Wallet init failed: $e');
    }
  }

  void _navigate(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onNavigate: _navigate,
        walletService: widget.walletService,
      ),
      TransferScreen(walletService: widget.walletService),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _navigate,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.north_east),
            selectedIcon: Icon(Icons.north_east),
            label: 'Send',
          ),
        ],
      ),
    );
  }
}
