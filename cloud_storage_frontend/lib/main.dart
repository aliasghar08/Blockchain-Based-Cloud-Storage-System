import 'package:flutter/material.dart';
import 'package:deceptra/core/theme.dart';
import 'package:deceptra/providers/wallet_provider.dart';
import 'package:deceptra/providers/wallet_state.dart';
import 'package:deceptra/services/notification_service.dart';
import 'package:deceptra/screens/login_screen.dart';
import 'package:deceptra/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService.initialize();

  final walletProvider = WalletProvider()..init();

  runApp(
    WalletState(
      provider: walletProvider,
      child: const CloudStorageApp(),
    ),
  );
}

class CloudStorageApp extends StatelessWidget {
  const CloudStorageApp({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = WalletState.of(context);

    return MaterialApp(
      title: 'Deceptra',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          if (walletProvider.isLoading && !walletProvider.isAuthenticated) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return walletProvider.isAuthenticated
              ? const DashboardScreen()
              : const LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
