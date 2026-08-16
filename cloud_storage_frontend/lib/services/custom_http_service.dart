import 'dart:io';

class CustomHttpService {
  /// Downloads a file from the given [url] to the specified [savePath].
  /// This replaces `dio.download(url, savePath)`.
  static Future<void> downloadFile(String url, String savePath) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download file. Status Code: \${response.statusCode}');
      }
      
      final file = File(savePath);
      final sink = file.openWrite();
      await response.pipe(sink);
      await sink.close();
    } finally {
      client.close();
    }
  }
}
