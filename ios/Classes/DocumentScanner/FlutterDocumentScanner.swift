
import AVFoundation
import EkycID
import Foundation

public class FlutterDocumentScanner: NSObject, FlutterPlatformView, DocumentScannerEventListener {
    let frame: CGRect
    let viewId: Int64
    var flutterCameraView: UIView?
    var cameraView: DocumentScannerView?
    var methodChannel: FlutterMethodChannel?
    var eventChannel: FlutterEventChannel?
    var eventStreamHandler: DocumentScannerEventStreamHandler?
    private let OBJECT_TYPE_MAPPING: [String: ObjectDetectionObjectType] = [
        "COVID_19_VACCINATION_CARD_0": ObjectDetectionObjectType.COVID_19_VACCINATION_CARD_0,

        "COVID_19_VACCINATION_CARD_0_BACK": ObjectDetectionObjectType.COVID_19_VACCINATION_CARD_0_BACK,

        "COVID_19_VACCINATION_CARD_1": ObjectDetectionObjectType.COVID_19_VACCINATION_CARD_1,

        "COVID_19_VACCINATION_CARD_1_BACK": ObjectDetectionObjectType.COVID_19_VACCINATION_CARD_1_BACK,

        "DRIVER_LICENSE_0": ObjectDetectionObjectType.DRIVER_LICENSE_0,

        "DRIVER_LICENSE_BACK_0": ObjectDetectionObjectType.DRIVER_LICENSE_0_BACK,

        "DRIVER_LICENSE_1": ObjectDetectionObjectType.DRIVER_LICENSE_1,

        "DRIVER_LICENSE_1_BACK": ObjectDetectionObjectType.DRIVER_LICENSE_1_BACK,

        "LICENSE_PLATE_0_0": ObjectDetectionObjectType.LICENSE_PLATE_0_0,

        "LICENSE_PLATE_0_1": ObjectDetectionObjectType.LICENSE_PLATE_0_1,

        "LICENSE_PLATE_1_0": ObjectDetectionObjectType.LICENSE_PLATE_1_0,

        "LICENSE_PLATE_2_0": ObjectDetectionObjectType.LICENSE_PLATE_2_0,

        "LICENSE_PLATE_3_0": ObjectDetectionObjectType.LICENSE_PLATE_3_0,

        "LICENSE_PLATE_3_1": ObjectDetectionObjectType.LICENSE_PLATE_3_1,

        "NATIONAL_ID_0": ObjectDetectionObjectType.NATIONAL_ID_0,

        "NATIONAL_ID_0_BACK": ObjectDetectionObjectType.NATIONAL_ID_0_BACK,

        "NATIONAL_ID_1": ObjectDetectionObjectType.NATIONAL_ID_1,

        "NATIONAL_ID_1_BACK": ObjectDetectionObjectType.NATIONAL_ID_1_BACK,

        "NATIONAL_ID_2": ObjectDetectionObjectType.NATIONAL_ID_2,

        "NATIONAL_ID_2_BACK": ObjectDetectionObjectType.NATIONAL_ID_2_BACK,

        "PASSPORT_0": ObjectDetectionObjectType.PASSPORT_0,

        "PASSPORT_0_:P": ObjectDetectionObjectType.PASSPORT_0_TOP,

        "SUPERFIT_0": ObjectDetectionObjectType.SUPERFIT_0,

        "SUPERFIT_0_BACK": ObjectDetectionObjectType.SUPERFIT_0_BACK,

        "VEHICLE_REGISTRATION_0": ObjectDetectionObjectType.VEHICLE_REGISTRATION_0,

        "VEHICLE_REGISTRATION_0_BACK": ObjectDetectionObjectType.VEHICLE_REGISTRATION_0_BACK,

        "VEHICLE_REGISTRATION_1": ObjectDetectionObjectType.VEHICLE_REGISTRATION_1,

        "VEHICLE_REGISTRATION_1_BACK": ObjectDetectionObjectType.VEHICLE_REGISTRATION_1_BACK,

        "VEHICLE_REGISTRATION_2": ObjectDetectionObjectType.VEHICLE_REGISTRATION_2
    ]

    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
        self.frame = frame
        self.viewId = viewId
        super.init()
        self.flutterCameraView = UIView(frame: frame)
        self.methodChannel = FlutterMethodChannel(name: "DocumentScanner_MethodChannel_" + String(viewId), binaryMessenger: messenger)
        self.eventChannel = FlutterEventChannel(name: "DocumentScanner_EventChannel_" + String(viewId), binaryMessenger: messenger)
        self.eventStreamHandler = DocumentScannerEventStreamHandler()
        self.methodChannel!.setMethodCallHandler(self.onMethodCall)
        self.eventChannel!.setStreamHandler(self.eventStreamHandler)
    }

    public func view() -> UIView {
        return self.flutterCameraView!
    }

    public func onDocumentScanned(mainSide: DocumentScannerResult, secondarySide: DocumentScannerResult?) {
        self.eventStreamHandler?.sendOnDocumentScannedEventToFlutter(mainSide, secondarySide)
    }

    private func start(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let args = call.arguments as! [String: Any?]
        let scannableDocuments = args["scannableDocuments"] as! [Any]
        let preparingDuration = args["preparingDuration"] as! Int

        self.cameraView = DocumentScannerView(
            frame: self.flutterCameraView!.frame
        )

        self.cameraView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.cameraView!.addListener(self)

        self.flutterCameraView!.addSubview(self.cameraView!)

        self.cameraView!.start(
            options: DocumentScannerOptions(
                cameraOptions: DocumentScannerCameraOptions(preparingDuration: preparingDuration),
                scannableDocuments: scannableDocuments.map({ _ in
                    ScannableDocument(mainSide: self.OBJECT_TYPE_MAPPING["NATIONAL_ID_0"]!, secondarySide: nil)
                }
                )
            )
        )

        print("fuck here")

        result(true)
    }

    private func dispose(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        if self.cameraView != nil {
            self.cameraView!.stop()
            self.cameraView = nil
        }
        result(true)
    }

    private func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            do {
                try self.start(call: call, result: result)
            } catch {
                result(FlutterError(code: "initialize Error", message: nil, details: nil))
            }
        case "dispose":
            do {
                try self.dispose(call: call, result: result)
            } catch {
                result(FlutterError(code: "dispose Error", message: nil, details: nil))
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func onInitialized() {
        print("on initalize swift")
        self.eventStreamHandler?.sendOnInitializedEventToFlutter()
    }

    public func onDetection(_ detection: DocumentScannerResult) {
        self.eventStreamHandler?.sendOnDetectionEventToFlutter(detection)
    }

    public func onFrame(_ frameStatus: FrameStatus) {
        self.eventStreamHandler?.sendOnFrameEventToFlutter(frameStatus)
    }

    public func onFrameStatusChanged(_ frameStatus: FrameStatus) {
        self.eventStreamHandler?.sendOnFrameStatusChangedEventToFlutter(frameStatus)
    }

    public func onCurrentSideChanged(_ currentSide: DocumentSide) {
        self.eventStreamHandler?.sendOnCurrentSideChangedEventToFlutter(currentSide)
    }

    class DocumentScannerEventStreamHandler: NSObject, FlutterStreamHandler {
        var events: FlutterEventSink?

        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            self.events = events
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            return nil
        }

        func sendOnDocumentScannedEventToFlutter(_ mainside: DocumentScannerResult, _ secondarySide: DocumentScannerResult?) {
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onDocumentScanned"
                    var values = [String: Any?]()
                    values["mainSide"] = DocumentScannerResult.toFlutterMap(mainside)
                    if secondarySide != nil {
                        values["secondarySide"] = DocumentScannerResult.toFlutterMap(secondarySide!)
                    } else {
                        values["secondarySide"] = nil
                    }
                    event["values"] = values
                    self.events!(event)
                }
            }
        }

        func sendOnFrameStatusChangedEventToFlutter(_ frameStatus: FrameStatus) {
            print("frame ", frameStatus)
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onFrameStatusChanged"
                    event["values"] = "DOCUMENT_NOT_FOUND"
                    self.events!(event)
                }
            }
        }

        func sendOnCurrentSideChangedEventToFlutter(_ currentSide: DocumentSide) {
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onCurrentSideChanged"
                    event["values"] = currentSide
                    self.events!(event)
                }
            }
        }

        func sendOnInitializedEventToFlutter() {
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onInitialized"
                    var values = [String: Any?]()
                    event["values"] = values
                    self.events!(event)
                }
            }
        }

        func sendOnFrameEventToFlutter(_ frameStatus: FrameStatus) {
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onFrame"
                    event["values"] = "DOCUMENT_NOT_FOUND"
                    self.events!(event)
                }
            }
        }

        func sendOnDetectionEventToFlutter(_ detection: DocumentScannerResult) {
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onDetection"
                    event["values"] = detection.toFlutterMap()
                    self.events!(event)
                }
            }
        }
    }
}

extension DocumentScannerResult {
    func toFlutterMap() -> [String: Any?] {
        var values = [String: Any?]()
        values["documentType"] = "\(self.documentType)"
        values["documentGroup"] = "\(self.documentGroup)"
        values["fullImage"] = FlutterStandardTypedData(bytes: self.fullImage.jpegData(compressionQuality: 0.8)!)
        values["documentImage"] = FlutterStandardTypedData(bytes: self.documentImage.jpegData(compressionQuality: 0.8)!)
        if self.faceImage != nil {
            values["faceImage"] = FlutterStandardTypedData(bytes: self.faceImage!.jpegData(compressionQuality: 0.8)!)
        } else {
            values["faceImage"] = nil
        }

        return values
    }
}
