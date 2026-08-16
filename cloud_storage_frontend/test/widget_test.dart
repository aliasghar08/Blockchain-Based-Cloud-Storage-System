import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deceptra/providers/wallet_state.dart';
import 'package:deceptra/main.dart';
import 'package:deceptra/providers/wallet_provider.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      WalletState(
        provider: WalletProvider(),
        child: const CloudStorageApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
