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
    var flutterCameraView: UIView?
    var cameraView: LivenessDetectionCameraView?
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
        self.flutterCameraView = UIView(frame: frame)
        self.methodChannel = FlutterMethodChannel(name: "LivenessDetection_MethodChannel_" + String(viewId), binaryMessenger: messenger)
        self.eventChannel = FlutterEventChannel(name: "LivenessDetection_EventChannel_" + String(viewId), binaryMessenger: messenger)
        self.eventStreamHandler = LivenessDetectionEventStreamHandler()
        self.methodChannel!.setMethodCallHandler(self.onMethodCall)
        self.eventChannel!.setStreamHandler(self.eventStreamHandler)
    }
    
    public func view() -> UIView {
        return self.flutterCameraView!
    }
    
    private func start(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let args = call.arguments as! [String: Any]?
        if (args != nil) {
            let prompts = args!["prompts"] as! [String]
            let promptTimerCountDownSec = args!["promptTimerCountDownSec"] as! Int
            self.cameraView = LivenessDetectionCameraView(
                frame: self.flutterCameraView!.frame,
                options: LivenessDetectionOptions(
                    prompts: prompts.map { e in
                        LIVENESS_PROMPT_TYPE_MAPPING[e]!
                    },
                    promptTimerCountDownSec: promptTimerCountDownSec
                )
            )
        } else {
            self.cameraView = LivenessDetectionCameraView(
                frame: self.flutterCameraView!.frame
            )
        }
        self.cameraView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.cameraView!.addListener(self)
        
        self.flutterCameraView!.addSubview(self.cameraView!)
        self.cameraView!.start()
        result(true)
    }
    
    
    private func dispose(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        if (self.cameraView != nil) {
            self.cameraView!.stop()
            self.cameraView = nil
        }
        result(true)
    }
    
    private func nextImage(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        self.cameraView!.nextImage()
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
    
    public func onInitialize() {
        self.eventStreamHandler?.sendOnInitializedEventToFlutter()
    }
    
    public func onFrame(frameStatus: FrameStatus) {
        self.eventStreamHandler?.sendOnFrameEventToFlutter(frameStatus)
    }
    
    public func onPromptCompleted(currentPrompt: LivenessPrompt, progress: Float) {
        self.eventStreamHandler?.sendOnPromptCompletedEventToFlutter(
            currentPrompt: currentPrompt,
            progress: progress
        )
    }
    
    public func onCountDownChanged(current: Int, max: Int) {
        self.eventStreamHandler?.sendOnCountDownChangedEventToFlutter(
            current: current,
            max: max
        )
    }
    
    public func onAllPromptsCompleted(detection: LivenessDetectionResult) {
        self.eventStreamHandler?.sendOnAllPromptsCompletedEventToFlutter(detection)
    }
    
    public func onFocus() {
        self.eventStreamHandler?.sendOnFocusEventToFlutter()
    }
    
    public func onFocusDropped() {
        self.eventStreamHandler?.sendOnFocusDroppedEventToFlutter()
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
        
        func sendOnAllPromptsCompletedEventToFlutter(_ detection: LivenessDetectionResult) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onAllPromptsCompleted"
                    event["values"] = detection.toFlutterMap()
                    self.events!(event)
                }
            }
        }
        
        func sendOnPromptCompletedEventToFlutter(currentPrompt: LivenessPrompt, progress: Float) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onPromptCompleted"
                    var values = [String: Any?]()
                    values["currentPrompt"] = currentPrompt.toFlutterMap()
                    values["progress"] = progress
                    event["values"] = values
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
        
        func sendOnFocusEventToFlutter() {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onFocus"
                    self.events!(event)
                }
            }
        }
        
        func sendOnFocusDroppedEventToFlutter() {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onFocusDropped"
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

extension LivenessDetectionResult {
    func toFlutterMap() -> [String: Any?] {
        var values = [String: Any?]()
        if (self.frontFace != nil) {
            values["frontFace"] = FlutterStandardTypedData(bytes: self.frontFace!.jpegData(compressionQuality: 0.8)!)
        } else {
            values["frontFace"] = nil
        }
        
        if (self.leftFace != nil) {
            values["leftFace"] = FlutterStandardTypedData(bytes: self.leftFace!.jpegData(compressionQuality: 0.8)!)
        } else {
            values["leftFace"] = nil
        }
        
        if (self.rightFace != nil) {
            values["rightFace"] = FlutterStandardTypedData(bytes: self.rightFace!.jpegData(compressionQuality: 0.8)!)
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
