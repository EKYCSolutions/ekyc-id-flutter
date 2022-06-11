import Flutter
import UIKit

public class SwiftEkycIdFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      registrar.register(DocumentScannerViewFactory(messenger: registrar.messenger()), withId: "DocumentScanner")
      registrar.register(LivenessDetectionViewFactory(messenger: registrar.messenger()), withId: "LivenessDetection")
  }
}
