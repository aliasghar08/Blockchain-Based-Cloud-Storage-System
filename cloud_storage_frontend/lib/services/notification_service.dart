import 'package:deceptra/services/custom_native_service.dart';

class NotificationService {
  static Future<void> initialize() async {
    // Initialization is handled natively in Android/iOS now
  }

  static Future<void> requestPermissions() async {
    await CustomNativeService.requestNotificationPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await CustomNativeService.showNotification(
      title: title,
      body: body,
    );
  }
}
