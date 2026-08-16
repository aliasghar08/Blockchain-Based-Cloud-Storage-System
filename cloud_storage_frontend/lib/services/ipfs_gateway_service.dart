import 'package:deceptra/services/custom_http_service.dart';
import 'package:deceptra/services/custom_native_service.dart';

class IpfsGatewayService {
  static const String _gatewayUrl = 'https://gateway.pinata.cloud/ipfs/';

  /// Opens the file directly in the browser using the IPFS gateway
  static Future<void> openInBrowser(String cid) async {
    final url = '\$_gatewayUrl\$cid';
    await CustomNativeService.launchUrl(url);
  }

  /// Downloads the file from IPFS to the local device storage
  static Future<String> downloadFile(String cid, String fileName) async {
    try {
      final url = '$_gatewayUrl$cid';
      
      // Get the appropriate directory from our native MethodChannel
      final directoryPath = await CustomNativeService.getDocumentsDirectory();

      final savePath = '$directoryPath/$fileName';
      
      await CustomHttpService.downloadFile(url, savePath);
      return savePath;
    } catch (e) {
      throw Exception('Failed to download file from IPFS: \$e');
    }
  }
}
