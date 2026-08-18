import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Set up the native method channel
    if let controller = window?.rootViewController as? FlutterViewController {
      let nativeChannel = FlutterMethodChannel(
        name: "fyp.cloudstorage/native",
        binaryMessenger: controller.binaryMessenger
      )

      nativeChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        switch call.method {

        case "launchUrl":
          if let args = call.arguments as? [String: Any],
             let urlString = args["url"] as? String,
             let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            result(nil)
          } else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "URL is null or invalid", details: nil))
          }

        case "getDocumentsDirectory":
          let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
          result(paths[0].path)

        case "requestNotificationPermission":
          UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
              result(granted)
            }
          }

        case "showNotification":
          if let args = call.arguments as? [String: Any],
             let title = args["title"] as? String,
             let body = args["body"] as? String {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            let request = UNNotificationRequest(
              identifier: UUID().uuidString,
              content: content,
              trigger: nil
            )
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            result(nil)
          } else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing title or body", details: nil))
          }

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
