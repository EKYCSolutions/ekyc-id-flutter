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
    
    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
        self.frame = frame
        self.viewId = viewId
        super.init()
        self.flutterCameraView = UIView(frame: frame)
        
        self.cameraView = LivenessDetectionCameraView(frame: self.flutterCameraView!.frame)
        self.cameraView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.cameraView!.addListener(self)
        
        self.flutterCameraView!.addSubview(self.cameraView!)
        
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
        self.cameraView!.start()
        result(true)
    }
    
    
    private func stop(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        self.cameraView!.stop()
        result(true)
    }
    
    private func nextImage(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        self.cameraView!.nextImage()
        result(true)
    }
    
    private func dispose(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
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
        case "stop":
            do {
                try self.stop(call: call, result: result)
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
    
    public func onPromptCompleted(currentPromptIndex: Int, progress: Float, success: Bool) {
        self.eventStreamHandler?.sendOnPromptCompletedEventToFlutter(
            currentPromptIndex: currentPromptIndex,
            progress: progress,
            success: success
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
        
        func sendOnPromptCompletedEventToFlutter(currentPromptIndex: Int, progress: Float, success: Bool) {
            if (self.events != nil) {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onPromptCompleted"
                    var values = [String: Any?]()
                    values["currentPromptIndex"] = currentPromptIndex
                    values["progress"] = progress
                    values["success"] = success
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
