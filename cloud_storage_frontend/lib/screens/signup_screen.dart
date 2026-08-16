import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deceptra/providers/wallet_state.dart';
import 'package:deceptra/screens/dashboard_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? _generatedPrivateKey;
  bool _isGenerating = false;

  void _generateWallet() {
    setState(() {
      _isGenerating = true;
    });

    final provider = WalletState.of(context);
    final key = provider.generateNewWallet();

    setState(() {
      _generatedPrivateKey = key;
      _isGenerating = false;
    });
  }

  Future<void> _handleLogin() async {
    if (_generatedPrivateKey == null) return;

    final provider = WalletState.of(context);
    final success = await provider.login(_generatedPrivateKey!);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Failed: \${provider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Wallet'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/Deceptra_logo.jpg',
                height: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Deceptra',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Instead of a username and password, your identity is secured by a cryptographic Private Key. We will generate one for you now locally on your device.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(height: 48),
              if (_generatedPrivateKey == null)
                ElevatedButton(
                  onPressed: _isGenerating ? null : _generateWallet,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isGenerating
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Generate New Wallet',
                          style: TextStyle(fontSize: 18),
                        ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'CRITICAL WARNING',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'If you lose this key, your account and files cannot be recovered. Copy it and save it somewhere extremely safe immediately.',
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Your Private Key:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _generatedPrivateKey!,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _generatedPrivateKey!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Private Key copied to clipboard!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: WalletState.of(context).isLoading ? null : _handleLogin,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: WalletState.of(context).isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "I have saved my Private Key, let's go!",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
