import 'package:flutter/material.dart';
import 'package:deceptra/providers/wallet_provider.dart';

/// A custom InheritedNotifier that replaces the 3rd-party `provider` package.
/// It listens to the [WalletProvider] (which extends ChangeNotifier) and 
/// rebuilds its dependent widgets whenever `notifyListeners()` is called.
class WalletState extends InheritedNotifier<WalletProvider> {
  const WalletState({
    super.key,
    required WalletProvider provider,
    required super.child,
  }) : super(notifier: provider);

  /// Helper method to easily access the [WalletProvider] from the BuildContext
  /// Usage: WalletState.of(context)
  static WalletProvider of(BuildContext context) {
    final WalletState? inherited = 
        context.dependOnInheritedWidgetOfExactType<WalletState>();
    if (inherited == null || inherited.notifier == null) {
      throw FlutterError('No WalletState found in context');
    }
    return inherited.notifier!;
  }
}
