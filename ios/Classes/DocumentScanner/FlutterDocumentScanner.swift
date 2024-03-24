
import AVFoundation
import EkycID
import Foundation

public class FlutterDocumentScanner: NSObject, FlutterPlatformView, DocumentScannerEventListener {
    let frame: CGRect
    let viewId: Int64
    var flutterScannerView: UIView?
    var scanner: DocumentScannerView!
    var methodChannel: FlutterMethodChannel?
    var eventChannel: FlutterEventChannel?
    var eventStreamHandler: DocumentScannerEventStreamHandler?

    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        print(frame.width)
        print(frame.height)
        
        self.frame = frame

        self.viewId = viewId

        super.init()
        self.flutterScannerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.methodChannel = FlutterMethodChannel(name: "DocumentScanner_MethodChannel_" + String(viewId), binaryMessenger: messenger)
        self.eventChannel = FlutterEventChannel(name: "DocumentScanner_EventChannel_" + String(viewId), binaryMessenger: messenger)
        self.eventStreamHandler = DocumentScannerEventStreamHandler()
        self.methodChannel!.setMethodCallHandler(self.onMethodCall)
        self.eventChannel!.setStreamHandler(self.eventStreamHandler)
    }

    public func view() -> UIView {
        return self.flutterScannerView!
    }

    private func start(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let args = call.arguments as! [String: Any?]
        self.scanner = DocumentScannerView(frame: self.flutterScannerView!.frame)
        self.scanner.addListener(self)
        self.scanner.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.flutterScannerView!.addSubview(self.scanner)
        self.scanner.start(options: self.argsToDocumentScannerOptions(args))
        result(true)
    }
    
    private func argsToDocumentScannerOptions(_ args: [String: Any?]) -> DocumentScannerOptions {
        let cameraOptions = args["cameraOptions"] as! [String: Any?]
        let captureDurationCountDown = cameraOptions["captureDurationCountDown"] as! Int
        let faceCropScale = cameraOptions["faceCropScale"] as! NSNumber
        let roiSize = cameraOptions["roiSize"] as! NSNumber
        let minDocWidthPercentage = cameraOptions["minDocWidthPercentage"] as! NSNumber
        let maxDocWidthPercentage = cameraOptions["maxDocWidthPercentage"] as! NSNumber
        let scannableDocuments = args["scannableDocuments"] as! [[String: Any]]
        return DocumentScannerOptions(
            cameraOptions: DocumentScannerCameraOptions(
                captureDurationCountDown: captureDurationCountDown,
                faceCropScale: faceCropScale.floatValue,
                roiSize: roiSize.floatValue,
                minDocWidthPercentage: minDocWidthPercentage.floatValue,
                maxDocWidthPercentage: maxDocWidthPercentage.floatValue
            ),
            scannableDocuments: scannableDocuments.map { e in
                var doc = e as! [String: String?]
                var mainSide = doc["mainSide"]!
                var secondarySide = doc["secondarySide"]!
                
                return ScannableDocument(
                    mainSide: StringToObjectDetectionObjectTypeMapping[mainSide!]!,
                    secondarySide: secondarySide != nil ? StringToObjectDetectionObjectTypeMapping[secondarySide!]! : nil
                )
            }
        )
    }
    
    public func onInitialized() {
        self.eventStreamHandler?.sendOnInitializedEventToFlutter()
    }
    
    public func onDocumentScanned(mainSide: EkycID.DocumentScannerResult, secondarySide: EkycID.DocumentScannerResult?) {
        self.eventStreamHandler?.sendOnDocumentScannedEventToFlutter(mainSide: mainSide, secondarySide: secondarySide)
    }
    
    public func onFrameStatusChanged(_ frameStatus: EkycID.FrameStatus) {
        self.eventStreamHandler?.sendOnFrameStatusChangedEventToFlutter(frameStatus)
    }
    
    public func onCurrentSideChanged(_ currentSide: EkycID.DocumentSide) {
        self.eventStreamHandler?.sendOnCurrentSideChangedEventToFlutter(currentSide)
    }
    
    public func onCaptureCountDownChanged(current: Int, max: Int) {
        self.eventStreamHandler?.sendOnCaptureCountDownChangedEventToFlutter(current: current, max: max)
    }
    
    private func nextImage(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        if self.scanner != nil {
            self.scanner.nextImage()
        }
        result(true)
    }

    private func dispose(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        if (self.scanner != nil) {
            self.scanner!.stop()
            self.scanner = nil
        }
        result(true)
    }
    
    private func reset(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        if (self.scanner != nil) {
            self.scanner!.reset()
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
            break
        case "nextImage":
            do {
                try self.nextImage(call: call, result: result)
            } catch {
                result(FlutterError(code: "dispose Error", message: nil, details: nil))
            }
            break
        case "reset":
            do {
                try self.reset(call: call, result: result)
            } catch {
                result(FlutterError(code: "dispose Error", message: nil, details: nil))
            }
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    class DocumentScannerEventStreamHandler: NSObject, FlutterStreamHandler {
        var events: FlutterEventSink?

        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            print("onListen")
            self.events = events
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            print("onCancel")
            return nil
        }

        func sendOnDocumentScannedEventToFlutter(_ mainside: DocumentScannerResult, _ secondarySide: DocumentScannerResult?) {
            print("sendOnDocumentScannedEventToFlutter")
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onInitialized"
                    self.events!(event)
                }
            }
        }
        
        func sendOnFrameStatusChangedEventToFlutter(_ frameStatus: FrameStatus) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onFrameStatusChanged"
                    event["values"] = "\(frameStatus)"
                    self.events!(event)
                }
            }
        }
        
        func sendOnCurrentSideChangedEventToFlutter(_ currentSide: EkycID.DocumentSide) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onCurrentSideChanged"
                    event["values"] = "\(currentSide)"
                    self.events!(event)
                }
            }
        }
        
        func sendOnDocumentScannedEventToFlutter(mainSide: EkycID.DocumentScannerResult, secondarySide: EkycID.DocumentScannerResult?) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onDocumentScanned"
                    
                    var result = [String: Any?]()
                    result["mainSide"] = mainSide.toFlutterMap()
                    if secondarySide != nil {
                        result["secondarySide"] = secondarySide!.toFlutterMap()
                    }
                    
                    event["values"] = result
                    self.events!(event)
                }
            }
        }
        
        func sendOnCaptureCountDownChangedEventToFlutter(current: Int, max: Int) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onCaptureCountDownChanged"
                    var result = [String: Any?]()
                    result["current"] = current
                    result["max"] = max
                    event["values"] = result
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
