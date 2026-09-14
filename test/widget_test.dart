import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crypto_pay/core/wallet/wallet_service.dart';
import 'package:crypto_pay/screens/home_screen.dart';
import 'package:crypto_pay/screens/transfer_screen.dart';

void main() {
  testWidgets('Disconnected home prompts wallet connect', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreen(
            onNavigate: (_) {},
            walletService: WalletService(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Connect wallet'), findsOneWidget);
    expect(find.text('No wallet connected'), findsOneWidget);
  });

  testWidgets('Send screen requires connect when disconnected', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransferScreen(walletService: WalletService()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Send'), findsOneWidget);
    expect(find.text('Connect wallet'), findsOneWidget);
  });
}
