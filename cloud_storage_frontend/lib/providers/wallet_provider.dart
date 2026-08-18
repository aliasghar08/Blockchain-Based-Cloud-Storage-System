import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/crypto.dart';
import 'package:deceptra/core/constants.dart';
import 'package:deceptra/models/file_model.dart';
import 'package:deceptra/services/blockchain_service.dart';

class WalletProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final BlockchainService _blockchainService = BlockchainService();

  final LocalAuthentication _localAuth = LocalAuthentication();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<FileModel> _myFiles = [];
  List<FileModel> _sharedFiles = [];

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<FileModel> get myFiles => _myFiles;
  List<FileModel> get sharedFiles => _sharedFiles;
  BlockchainService get blockchainService => _blockchainService;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedKey = await _secureStorage.read(key: Constants.privateKeyStorageKey);
      if (savedKey != null && savedKey.isNotEmpty) {
        // Authenticate with biometrics before auto-login
        bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
        bool isDeviceSupported = await _localAuth.isDeviceSupported();
        
        bool didAuthenticate = true;
        if (canCheckBiometrics || isDeviceSupported) {
          try {
            didAuthenticate = await _localAuth.authenticate(
              localizedReason: 'Please authenticate to access your Cloud Storage Wallet',
            );
          } catch (_) {
            didAuthenticate = false;
          }
        }
        
        if (didAuthenticate) {
          await login(savedKey, saveKey: false);
        } else {
          _errorMessage = 'Biometric authentication failed. Please login manually.';
        }
      }
    } catch (e) {
      debugPrint('Error reading secure storage: \$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String privateKey, {bool saveKey = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate and init blockchain service
      await _blockchainService.init(privateKey);

      if (saveKey) {
        await _secureStorage.write(
            key: Constants.privateKeyStorageKey, value: privateKey);
      }

      _isAuthenticated = true;
      await fetchMyFiles();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: Constants.privateKeyStorageKey);
    _isAuthenticated = false;
    _myFiles = [];
    _sharedFiles = [];
    notifyListeners();
  }

  Future<void> fetchMyFiles() async {
    if (!_isAuthenticated) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myFiles = await _blockchainService.getMyFiles();
      _sharedFiles = await _blockchainService.getSharedWithMe();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching files: \$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generates a new Ethereum wallet (Private Key)
  String generateNewWallet() {
    final rng = Random.secure();
    final credentials = EthPrivateKey.createRandom(rng);
    final privateKey = bytesToHex(credentials.privateKey);
    return privateKey;
  }
}
