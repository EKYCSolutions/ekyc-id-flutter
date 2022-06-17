//
//  FlutterDocumentScanner.swift
//  ekyc_id_flutter
//
//  Created by Socret Lee on 6/11/22.
//
import EkycID
import Foundation
import AVFoundation

public class FlutterDocumentScanner: NSObject, FlutterPlatformView, DocumentScannerEventListener {
    let frame: CGRect
    let viewId: Int64
    var flutterCameraView: UIView?
    var cameraView: DocumentScannerCameraView?
    var methodChannel: FlutterMethodChannel?
    var eventChannel: FlutterEventChannel?
    var eventStreamHandler: DocumentScannerEventStreamHandler?
    
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
    
    private func start(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let args = call.arguments as! [String: Any?]
        self.cameraView = DocumentScannerCameraView(
            frame: self.flutterCameraView!.frame,
            options: DocumentScannerOptions(
                preparingDuration: args["preparingDuration"]! as! Int
            )
        )
        self.cameraView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.cameraView!.addListener(self)
        self.flutterCameraView!.addSubview(self.cameraView!)
        self.cameraView!.start()
        result(true)
    }
    
    private func setWhiteList(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let args = call.arguments as! [String]
        self.cameraView!.setWhiteList(whiteList: args)
        result(true)
    }
    
    private func nextImage(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        self.cameraView!.nextImage()
        result(true)
    }
    
    private func dispose(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        if (self.cameraView != nil) {
            self.cameraView!.stop()
            self.cameraView = nil
        }
        result(true)
    }
    
    private func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
        switch (call.method) {
        case "start":
            do {
                try self.start(call: call, result: result)
            } catch {
                result(FlutterError(code: "initialize Error", message: nil, details: nil))
            }
            break
        case "dispose":
            do {
                try self.dispose(call: call, result: result)
            } catch {
                result(FlutterError(code: "dispose Error", message: nil, details: nil))
            }
            break
        case "setWhiteList":
            do {
                try self.setWhiteList(call: call, result: result)
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
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    public func onInitialize() {
        self.eventStreamHandler?.sendOnInitializedEventToFlutter()
    }
    
    public func onDetection(detection: DocumentScannerResult) {
        self.eventStreamHandler?.sendOnDetectionEventToFlutter(detection)
    }
    
    public func onFrame(frameStatus: FrameStatus) {
        self.eventStreamHandler?.sendOnFrameEventToFlutter(frameStatus)
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
        
        func sendOnInitializedEventToFlutter() {
            if (self.events != nil) {
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
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onFrame"
                    event["values"] = "\(frameStatus)"
                    self.events!(event)
                }
            }
        }
        
        func sendOnDetectionEventToFlutter(_ detection: DocumentScannerResult) {
            if (self.events != nil) {
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
        if (self.faceImage != nil) {
            values["faceImage"] = FlutterStandardTypedData(bytes: self.faceImage!.jpegData(compressionQuality: 0.8)!)
        } else {
            values["faceImage"] = nil
        }
        
        return values
    }
}
