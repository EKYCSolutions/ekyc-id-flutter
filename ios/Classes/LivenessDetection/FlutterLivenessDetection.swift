//
//  FlutterLivenessDetection.swift
//  ekyc_id_flutter
//
//  Created by Socret Lee on 6/11/22.
//

import EkycID
import Foundation
import AVFoundation

public class FlutterLivenessDetection: NSObject, FlutterPlatformView, LivenessDetectionEventListener {
    let frame: CGRect
    let viewId: Int64
    var flutterScannerView: UIView?
    var scanner: LivenessDetectionView?
    var methodChannel: FlutterMethodChannel?
    var eventChannel: FlutterEventChannel?
    var eventStreamHandler: LivenessDetectionEventStreamHandler?
    
    let LIVENESS_PROMPT_TYPE_MAPPING: [String: LivenessPromptType] = [
        "BLINKING": .BLINKING,
        "LOOK_LEFT": .LOOK_LEFT,
        "LOOK_RIGHT": .LOOK_RIGHT,
    ]
    
    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
        self.frame = frame
        self.viewId = viewId
        super.init()
        self.flutterScannerView = UIView(frame: frame)
        self.methodChannel = FlutterMethodChannel(name: "LivenessDetection_MethodChannel_" + String(viewId), binaryMessenger: messenger)
        self.eventChannel = FlutterEventChannel(name: "LivenessDetection_EventChannel_" + String(viewId), binaryMessenger: messenger)
        self.eventStreamHandler = LivenessDetectionEventStreamHandler()
        self.methodChannel!.setMethodCallHandler(self.onMethodCall)
        self.eventChannel!.setStreamHandler(self.eventStreamHandler)
    }
    
    public func view() -> UIView {
        return self.flutterScannerView!
    }
    
    private func start(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let args = call.arguments as! [String: Any]
        let prompts = args["prompts"] as! [String]
        let promptTimerCountDownSec = args["promptTimerCountDownSec"] as! Int
        self.scanner = LivenessDetectionView(frame: self.flutterScannerView!.frame)
        self.scanner!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scanner!.addListener(self)
        self.scanner!.start(
            options: LivenessDetectionOptions(
                cameraOptions: LivenessDetectionCameraOptions(
                    prompts: prompts.map { e in
                        LIVENESS_PROMPT_TYPE_MAPPING[e]!
                    },
                    promptTimerCountDownSec: promptTimerCountDownSec
                )
            )
        )
        
        self.flutterScannerView!.addSubview(self.scanner!)
        result(true)
    }
    
    
    private func dispose(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        if (self.scanner != nil) {
            self.scanner!.stop()
            self.scanner = nil
        }
        result(true)
    }
    
    private func nextImage(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        self.scanner!.nextImage()
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
    
    public func onInitialized() {
        eventStreamHandler?.sendOnInitializedEventToFlutter()
    }
    
    public func onFocusChanged(_ isFocusing: Bool) {
        eventStreamHandler?.sendOnFocusChangedEventToFlutter(isFocusing)
    }
    
    public func onProgressChanged(_ progress: Float) {
        eventStreamHandler?.sendOnProgressChangedEventToFlutter(progress)
    }
    
    public func onCountDownChanged(current: Int, max: Int) {
        eventStreamHandler?.sendOnCountDownChangedEventToFlutter(
            current: current,
            max: max
        )
    }
    
    public func onFrameStatusChanged(_ frameStatus: EkycID.FrameStatus) {
        eventStreamHandler?.sendOnFrameStatusChangedEventToFlutter(frameStatus)
    }
    
    public func onActivePromptChanged(_ activePrompt: EkycID.LivenessPromptType?) {
        eventStreamHandler?.sendOnActivePromptChangedToFlutter(activePrompt)
    }
    
    public func onLivenessTestCompleted(_ result: EkycID.LivenessDetectionResult) {
        eventStreamHandler?.sendOnLivenessTestCompletedEventToFlutter(result)
    }
    
    class LivenessDetectionEventStreamHandler: NSObject, FlutterStreamHandler {
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

        func sendOnCountDownChangedEventToFlutter(current: Int, max: Int) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onCountDownChanged"
                    var values = [String: Any?]()
                    values["current"] = current
                    values["max"] = max
                    event["values"] = values
                    self.events!(event)
                }
            }
        }
        
        func sendOnFocusChangedEventToFlutter(_ isFocusing: Bool) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onFocusChanged"
                    event["value"] = isFocusing
                    self.events!(event)
                }
            }
        }
        
        func sendOnProgressChangedEventToFlutter(_ progress: Float) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onProgressChanged"
                    event["value"] = progress
                    self.events!(event)
                }
            }
        }
        
        func sendOnFrameStatusChangedEventToFlutter(_ frameStatus: EkycID.FrameStatus) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onFrameStatusChanged"
                    event["values"] = "\(frameStatus)"
                    self.events!(event)
                }
            }
        }
        
        func sendOnActivePromptChangedToFlutter(_ activePrompt: EkycID.LivenessPromptType?) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onActivePromptChanged"
                    if (activePrompt != nil) {
                        event["values"] = "\(activePrompt)"
                    }
                    self.events!(event)
                }
            }
        }
        
        func sendOnLivenessTestCompletedEventToFlutter(_ result: LivenessDetectionResult) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onLivenessTestCompleted"
                    event["values"] = result.toFlutterMap()
                    self.events!(event)
                }
            }
        }
    }
}

extension LivenessPrompt {
    func toFlutterMap() -> [String: Any?] {
        var values = [String: Any?]()
        values["prompt"] = "\(self.prompt)"
        values["success"] = self.success
        return values
    }
}

extension LivenessFace {
    func toFlutterMap() -> [String: Any?] {
        var values = [String: Any?]()
        values["image"] = FlutterStandardTypedData(bytes: self.image!.jpegData(compressionQuality: 0.8)!)
        values["leftEyeOpenProbability"] = self.leftEyeOpenProbability
        values["rightEyeOpenProbability"] = self.rightEyeOpenProbability
        values["headEulerAngleX"] = self.headEulerAngleX
        values["headEulerAngleY"] = self.headEulerAngleY
        values["headEulerAngleZ"] = self.headEulerAngleZ
        
        if (self.headDirection != nil) {
            values["headDirection"] = "\(self.headDirection!)"
        } else {
            values["headDirection"] = nil
        }
        
        if (self.eyesStatus != nil) {
            values["eyesStatus"] = "\(self.eyesStatus!)"
        } else {
            values["eyesStatus"] = nil
        }
        return values
    }
}

extension LivenessDetectionResult {
    func toFlutterMap() -> [String: Any?] {
        var values = [String: Any?]()
        if (self.frontFace != nil) {
            values["frontFace"] = self.frontFace!.toFlutterMap()
        } else {
            values["frontFace"] = nil
        }
        
        if (self.leftFace != nil) {
            values["leftFace"] = self.leftFace!.toFlutterMap()
        } else {
            values["leftFace"] = nil
        }
        
        if (self.rightFace != nil) {
            values["rightFace"] = self.rightFace!.toFlutterMap()
        } else {
            values["rightFace"] = nil
        }
        
        values["prompts"] = self.prompts.map {e -> [String:Any?] in
            var v = [String:Any?]()
            v["prompt"]="\(e.prompt)"
            v["success"]=e.success
            return v
        }
        
        return values
    }
}
