import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:deceptra/core/constants.dart';

class PinataService {
  static const String pinataApiUrl = 'https://api.pinata.cloud/pinning/pinFileToIPFS';

  /// Uploads a file to IPFS and returns the CID (Hash)
  static Future<String?> uploadFileToIPFS(File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(pinataApiUrl));
      
      request.headers.addAll({
        'Authorization': 'Bearer ${Constants.pinataJwt}',
      });

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData);
        String cid = jsonResponse['IpfsHash'];
        debugPrint('File successfully uploaded to IPFS! CID: $cid');
        return cid;
      } else {
        debugPrint('Pinata Upload Failed: $responseData');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading to Pinata: $e');
      return null;
    }
  }
}
