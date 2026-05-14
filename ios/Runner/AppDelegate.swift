import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller = window?.rootViewController as! FlutterViewController
    let audioChannel = FlutterMethodChannel(name: "com.example.music_reading/audio",
                                           binaryMessenger: controller.binaryMessenger)
    audioChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "startListening":
        // TODO: Implement AudioKit integration
        result(nil)
      case "stopListening":
        // TODO: Implement stop logic
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
