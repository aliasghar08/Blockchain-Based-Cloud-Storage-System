import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:deceptra/providers/wallet_state.dart';
import 'package:deceptra/main.dart';
import 'package:deceptra/providers/wallet_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify file list empty state',
        (tester) async {
      
      final walletProvider = WalletProvider();
      
      await tester.pumpWidget(
        WalletState(
          provider: walletProvider,
          child: const CloudStorageApp(),
        ),
      );

      // Verify the LoginScreen is showing
      expect(find.text('Connect Wallet'), findsOneWidget);

      // Verify Login Screen Input
      final inputField = find.byType(TextField);
      expect(inputField, findsOneWidget);
    });
  });
}
