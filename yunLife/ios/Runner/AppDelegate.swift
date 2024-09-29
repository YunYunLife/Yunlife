import Flutter
import UIKit
import GoogleMaps // 导入 Google Maps

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBC-dgev6A7c0qdnxHr_KCzhfEibsRDDQw") // 设置 API 密钥
    GeneratedPluginRegistrant.register(with: self)
    return true
  }
}
