
import AVFoundation
import EkycID
import Foundation

public class FlutterLivenessDetection: NSObject, FlutterPlatformView, LivenessDetectionEventListener {
    let frame: CGRect
    let viewId: Int64
    var flutterCameraView: UIView?
    var cameraView: LivenessDetectionView?
    var methodChannel: FlutterMethodChannel?
    var eventChannel: FlutterEventChannel?
    var eventStreamHandler: LivenessDetectionEventStreamHandler?
    
    let LIVENESS_PROMPT_TYPE_MAPPING: [String: LivenessPromptType] = [
        "BLINKING": .BLINKING,
        "LOOK_LEFT": .LOOK_LEFT,
        "LOOK_RIGHT": .LOOK_RIGHT,
    ]
    
    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        self.frame = frame
        self.viewId = viewId
        super.init()
        self.flutterCameraView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
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
        let args = call.arguments as! [String: Any]

        let promptTimerCountDownSec = args["promptTimerCountDownSec"] as! Int
      
        self.cameraView = LivenessDetectionView(
            frame: self.flutterCameraView!.frame
        )
        
        self.cameraView!.setLang(lang: LivenessDetectionOverlayOptions(language: EkycIDLanguage.EN))
        
        self.cameraView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.cameraView!.addListener(self)

        self.flutterCameraView!.addSubview(self.cameraView!)
        self.cameraView!.start(
            options: LivenessDetectionOptions(
                cameraOptions: LivenessDetectionCameraOptions(promptTimerCountDownSec: promptTimerCountDownSec)
            )
        )
        
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
    
    public func onInitialize() {
        self.eventStreamHandler?.sendOnInitializedEventToFlutter()
    }
    
    public func onLivenessTestCompleted(_ result: LivenessDetectionResult) {
        self.eventStreamHandler?.sendOnLivenessTestCompletedEventToFlutter(result)
    }
    
    public func onFrameStatusChanged(_ frameStatus: FrameStatus) {
        self.eventStreamHandler?.sendOnFrameStatusChangedEventToFlutter(frameStatus)
    }
    
    public func onProgressChanged(_ progress: Float) {
        self.eventStreamHandler?.sendOnProgressChangedEventToFlutter(progress)
    }
    
    public func onFocusChanged(_ isFocusing: Bool) {
        self.eventStreamHandler?.sendOnFocusChangedEventToFlutter(isFocusing)
    }
    
    public func onActivePromptChanged(_ activePrompt: LivenessPromptType?) {
        self.eventStreamHandler?.sendOnActivePromptChanged(activePrompt)
    }
    
    public func onCountDownChanged(current: Int, max: Int) {
        self.eventStreamHandler?.sendOnCountDownChangedEventToFlutter(current: current, max: max)
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
            print("sendOnInitializedEventToFlutter")
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onInitialized"
                    self.events!(event)
                }
            }
        }
        
        func sendOnFrameStatusChangedEventToFlutter(_ frameStatus: FrameStatus) {
            print("sendOnFrameStatusChangedEventToFlutter")
            
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onFrameStatusChanged"
                    event["values"] = "\(frameStatus.rawValue)"
                    self.events!(event)
                }
            }
        }
        
        func sendOnProgressChangedEventToFlutter(_ progress: Float) {
            print("sendOnProgressChangedEventToFlutter")
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onProgressChanged"
                    var values = [String: Any?]()
                    values["progress"] = progress
                    event["values"] = values
                 
                    
                    self.events!(event)
                }
            }
        }
        
        func sendOnFocusChangedEventToFlutter(_ isFocusing: Bool) {
            print("sendOnFocusChangedEventToFlutter", isFocusing)
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onFocusChanged"
                    event["values"] = isFocusing
                    self.events!(event)
                }
            }
        }
        
        func sendOnActivePromptChanged(_ activePrompt: LivenessPromptType?) {
            print("sendOnActivePromptChanged")
        
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onActivePromptChanged"
                    event["values"] = activePrompt?.rawValue
                    self.events!(event)
                }
            }
        }
        
        func sendOnCountDownChangedEventToFlutter(current: Int, max: Int) {
            print("sendOnCountDownChangedEventToFlutter")
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onCountDownChanged"
                    var values = [String: Any]()
                    values["current"] = current
                    values["max"] = max
                    event["values"] = values
              
                    self.events!(event)
                }
            }
        }
        
        func sendOnLivenessTestCompletedEventToFlutter(_ result: LivenessDetectionResult) {
            print("sendOnLivenessTestCompletedEventToFlutter")
            if self.events != nil {
                DispatchQueue.main.async {
                    var event = [String: Any]()
                    event["type"] = "onLivenessActivecompleted"
                    let values = result.toFlutterMap()
                    event["values"] = values
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
        
        if self.headDirection != nil {
            values["headDirection"] = "\(self.headDirection!)"
        } else {
            values["headDirection"] = nil
        }
        
        if self.eyesStatus != nil {
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
        if self.frontFace != nil {
            values["frontFace"] = self.frontFace!.toFlutterMap()
        } else {
            values["frontFace"] = nil
        }
        
        if self.leftFace != nil {
            values["leftFace"] = self.leftFace!.toFlutterMap()
        } else {
            values["leftFace"] = nil
        }
        
        if self.rightFace != nil {
            values["rightFace"] = self.rightFace!.toFlutterMap()
        } else {
            values["rightFace"] = nil
        }
        
        values["prompts"] = self.prompts.map { e -> [String: Any?] in
            var v = [String: Any?]()
            v["prompt"] = "\(e.prompt)"
            v["success"] = e.success
            return v
        }
        
        return values
    }
}
