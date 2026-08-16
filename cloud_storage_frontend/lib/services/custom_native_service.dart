import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class CustomNativeService {
  static const MethodChannel _channel = MethodChannel('fyp.cloudstorage/native');

  /// Opens a URL in the native browser
  static Future<void> launchUrl(String url) async {
    try {
      await _channel.invokeMethod('launchUrl', {'url': url});
    } catch (e) {
      debugPrint('Failed to launch URL: $e');
      throw Exception('Could not launch URL');
    }
  }

  /// Gets the absolute path to the app's document directory
  static Future<String> getDocumentsDirectory() async {
    try {
      final String path = await _channel.invokeMethod('getDocumentsDirectory');
      return path;
    } catch (e) {
      debugPrint('Failed to get documents directory: $e');
      throw Exception('Could not get documents directory');
    }
  }

  /// Requests notification permission (POST_NOTIFICATIONS on Android 13+, UNUserNotificationCenter on iOS)
  static Future<bool> requestNotificationPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('requestNotificationPermission');
      return granted;
    } catch (e) {
      debugPrint('Failed to request notification permission: $e');
      return false;
    }
  }

  /// Shows a local notification
  static Future<void> showNotification({required String title, required String body}) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'title': title,
        'body': body,
      });
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }
}
