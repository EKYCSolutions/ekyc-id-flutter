//
//  FlutterFaceDetection.swift
//  ekyc_id_flutter
//
//  Created by Socret Lee on 3/17/24.
//

import Foundation
import EkycID

public class FlutterFaceDetection: NSObject, FlutterPlugin {
    var detector: FaceDetection? = nil
        
    public static func register(with registrar: any FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "FaceDetection_MethodChannel", binaryMessenger: registrar.messenger())
        let instance = FlutterFaceDetection()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        self.detector = FaceDetection.Builder().setModelType(modelType: .GOOGLE).build()
        result(true)
    }
    
    private func dispose(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        if (self.detector != nil) {
            self.detector = nil
        }
        result(true)
    }
    
    public func detect(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let imageBytes = call.arguments as! FlutterStandardTypedData
        let image = UIImage(data:Data(imageBytes.data))
        let img = UIImage(cgImage: image!.cgImage!)

        let detections = self.detector!.detect(image: img)
        if detections == nil || detections?.count ?? 0 <= 0 {
            result([])
        }
        
        result(detections!.map({ face in
            
            var faceImageCG = ImageUtils.cropBoundingBox(
                image: img.cgImage!,
                bbox: face.bbox,
                scale: 1.2
            )
            
            if (image?.imageOrientation == .left) {
                faceImageCG = faceImageCG.rotate(orienation: .right)!
            } else if (image?.imageOrientation == .up) {
                faceImageCG = faceImageCG.rotate(orienation: .up)!
            } else if (image?.imageOrientation == .down) {
                faceImageCG = faceImageCG.rotate(orienation: .down)!
            } else if (image?.imageOrientation == .right) {
                faceImageCG = faceImageCG.rotate(orienation: .left)!
            }
            
            let faceImage = UIImage(cgImage: faceImageCG)
            
            return EkycID.LivenessFace(
                image: faceImage,
                leftEyeOpenProbability: face.leftEyeOpenProbability,
                rightEyeOpenProbability: face.rightEyeOpenProbability,
                headEulerAngleX: face.headEulerAngleX,
                headEulerAngleY: face.headEulerAngleY,
                headEulerAngleZ: face.headEulerAngleZ,
                headDirection: face.headDirection,
                eyesStatus: face.eyesStatus
            ).toFlutterMap()
        }))
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "initialize":
            do {
                try self.initialize(call: call, result: result)
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
        case "detect":
            do {
                try self.detect(call: call, result: result)
            } catch {
                result(FlutterError(code: "detect Error", message: nil, details: nil))
            }
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
}
