//
//  FlutterFaceScanner.swift
//  ekyc_id_flutter
//
//  Created by Socret Lee on 3/16/24.
//

import EkycID
import Foundation
import AVFoundation

public class FlutterFaceScanner: NSObject, FlutterPlatformView, FaceScannerEventListener {
    let viewId: Int64
    var flutterScannerView: UIView?
    var scanner: FaceScannerView!
    var methodChannel: FlutterMethodChannel?
    var eventChannel: FlutterEventChannel?
    var eventStreamHandler: FaceScannerEventStreamHandler?
    
    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        self.viewId = viewId
        
        super.init()
        
        self.flutterScannerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.methodChannel = FlutterMethodChannel(name: "FaceScanner_MethodChannel_" + String(viewId), binaryMessenger: messenger)
        self.eventChannel = FlutterEventChannel(name: "FaceScanner_EventChannel_" + String(viewId), binaryMessenger: messenger)
        self.eventStreamHandler = FaceScannerEventStreamHandler()
        self.methodChannel!.setMethodCallHandler(self.onMethodCall)
        self.eventChannel!.setStreamHandler(self.eventStreamHandler)
    }
    
    public func view() -> UIView {
        return self.flutterScannerView!
    }
    
    private func start(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let args = call.arguments as! [String: Any?]
        let useFrontCamera = args["useFrontCamera"] as! Bool
        self.scanner = FaceScannerView(
            frame: self.flutterScannerView!.frame,
            useFrontCamera: useFrontCamera
        )
        self.scanner.addListener(self)
        self.scanner.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.flutterScannerView!.addSubview(self.scanner)
        self.scanner.start(options: self.argsToFaceScannerOptions(args))
        result(true)
    }
    
    private func argsToFaceScannerOptions(_ args: [String: Any?]) -> FaceScannerOptions {
        let cameraOptions = args["cameraOptions"] as! [String: Any?]
        let captureDurationCountDown = cameraOptions["captureDurationCountDown"] as! Int
        let faceCropScale = cameraOptions["faceCropScale"] as! NSNumber
        let roiSize = cameraOptions["roiSize"] as! NSNumber
        let minFaceWidthPercentage = cameraOptions["minFaceWidthPercentage"] as! NSNumber
        let maxFaceWidthPercentage = cameraOptions["maxFaceWidthPercentage"] as! NSNumber
        return FaceScannerOptions(
            cameraOptions: FaceScannerCameraOptions(
                captureDurationCountDown: captureDurationCountDown,
                faceCropScale: faceCropScale.floatValue,
                roiSize: roiSize.floatValue,
                minFaceWidthPercentage: minFaceWidthPercentage.floatValue,
                maxFaceWidthPercentage: maxFaceWidthPercentage.floatValue
            )
        )
    }
    
    public func onInitialized() {
        self.eventStreamHandler?.sendOnInitializedEventToFlutter()
    }
    
    public func onFaceScanned(_ face: EkycID.LivenessFace) {
        self.eventStreamHandler?.sendOnFaceScannedEventToFlutter(face)
    }
    
    public func onFrameStatusChanged(_ frameStatus: EkycID.FrameStatus) {
        self.eventStreamHandler?.sendOnFrameStatusChangedEventToFlutter(frameStatus)
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
    
    class FaceScannerEventStreamHandler: NSObject, FlutterStreamHandler {
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
        
        func sendOnFaceScannedEventToFlutter(_ face: EkycID.LivenessFace) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onFaceScanned"
                    event["values"] = face.toFlutterMap()
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
