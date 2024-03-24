import Flutter
import UIKit

public class SwiftEkycIdFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      registrar.register(DocumentScannerViewFactory(messenger: registrar.messenger()), withId: "DocumentScanner")
      registrar.register(LivenessDetectionViewFactory(messenger: registrar.messenger()), withId: "LivenessDetection")
      registrar.register(FaceScannerViewFactory(messenger: registrar.messenger()), withId: "FaceScanner")
      //
      FlutterFaceDetection.register(with: registrar)
      FlutterDocumentDetection.register(with: registrar)
  }
}
