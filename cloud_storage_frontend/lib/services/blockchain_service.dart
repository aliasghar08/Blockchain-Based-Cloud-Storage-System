import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:deceptra/core/constants.dart';
import 'package:deceptra/core/abi.dart';
import 'package:deceptra/models/file_model.dart';

class BlockchainService {
  late Web3Client _client;
  late EthPrivateKey _credentials;
  late DeployedContract _contract;

  late ContractFunction _uploadFile;
  late ContractFunction _shareFile;
  late ContractFunction _getMyFiles;
  late ContractFunction _getSharedWithMe;

  bool _isInitialized = false;

  String get blockchainAddress => _isInitialized ? _credentials.address.hexEip55 : '';

  Future<void> init(String privateKey) async {
    if (_isInitialized) return;

    _client = Web3Client(Constants.rpcUrl, Client());
    
    try {
      _credentials = EthPrivateKey.fromHex(privateKey);
    } catch (e) {
      throw Exception('Invalid private key format.');
    }

    final contractAbi = ContractAbi.fromJson(AppABI.cloudStorageABI, 'CloudStorage');
    final contractAddress = EthereumAddress.fromHex(Constants.contractAddress);

    _contract = DeployedContract(contractAbi, contractAddress);

    _uploadFile = _contract.function('uploadFile');
    _shareFile = _contract.function('shareFile');
    _getMyFiles = _contract.function('getMyFiles');
    _getSharedWithMe = _contract.function('getSharedWithMe');

    _isInitialized = true;
  }

  /// Upload a file to the blockchain
  Future<String> uploadFile(String cid, String fileName, int fileSize, String fileType) async {
    if (!_isInitialized) throw Exception('Blockchain service not initialized.');
    
    try {
      final transaction = Transaction.callContract(
        contract: _contract,
        function: _uploadFile,
        parameters: [cid, fileName, BigInt.from(fileSize), fileType],
      );

      final txHash = await _client.sendTransaction(
        _credentials,
        transaction,
        chainId: Constants.chainId,
      );
      
      return txHash;
    } catch (e) {
      throw Exception('Error uploading file to blockchain: \$e');
    }
  }

  /// Share a file with another user
  Future<String> shareFile(String cid, String userAddressHex) async {
    if (!_isInitialized) throw Exception('Blockchain service not initialized.');

    try {
      final userAddress = EthereumAddress.fromHex(userAddressHex);
      final transaction = Transaction.callContract(
        contract: _contract,
        function: _shareFile,
        parameters: [cid, userAddress],
      );

      final txHash = await _client.sendTransaction(
        _credentials,
        transaction,
        chainId: Constants.chainId,
      );
      
      return txHash;
    } catch (e) {
      throw Exception('Error sharing file on blockchain: \$e');
    }
  }

  /// Get the current user's files
  Future<List<FileModel>> getMyFiles() async {
    if (!_isInitialized) throw Exception('Blockchain service not initialized.');

    try {
      final result = await _client.call(
        contract: _contract,
        function: _getMyFiles,
        params: [],
        sender: _credentials.address,
      );

      if (result.isEmpty) return [];

      final filesData = result[0] as List<dynamic>;
      
      return filesData.map((fileRecord) {
        final data = fileRecord as List<dynamic>;
        final ownerAddress = data[4] as EthereumAddress;
        
        return FileModel(
          cid: data[0].toString(),
          fileName: data[1].toString(),
          fileSize: (data[2] as BigInt).toInt(),
          fileType: data[3].toString(),
          owner: ownerAddress.hexEip55,
          uploadTime: DateTime.fromMillisecondsSinceEpoch(
              (data[5] as BigInt).toInt() * 1000),
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching files from blockchain: \$e');
    }
  }

  /// Get files shared with the current user
  Future<List<FileModel>> getSharedWithMe() async {
    if (!_isInitialized) throw Exception('Blockchain service not initialized.');

    try {
      final result = await _client.call(
        contract: _contract,
        function: _getSharedWithMe,
        params: [],
        sender: _credentials.address,
      );

      if (result.isEmpty) return [];

      final filesData = result[0] as List<dynamic>;
      
      return filesData.map((fileRecord) {
        final data = fileRecord as List<dynamic>;
        final ownerAddress = data[4] as EthereumAddress;
        
        return FileModel(
          cid: data[0].toString(),
          fileName: data[1].toString(),
          fileSize: (data[2] as BigInt).toInt(),
          fileType: data[3].toString(),
          owner: ownerAddress.hexEip55,
          uploadTime: DateTime.fromMillisecondsSinceEpoch(
              (data[5] as BigInt).toInt() * 1000),
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching shared files from blockchain: \$e');
    }
  }
}
