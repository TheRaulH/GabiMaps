import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyAsRsy9MnCwnj-KTk7GkXU8jPP1BimODhI")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
