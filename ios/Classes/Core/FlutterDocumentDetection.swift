//
//  FlutterDocumentDetection.swift
//  ekyc_id_flutter
//
//  Created by Socret Lee on 3/18/24.
//

import Foundation
import EkycID

public class FlutterDocumentDetection: NSObject, FlutterPlugin {
    private var faceDetector: FaceDetection?
    private var edgeDetector: EdgeDetection?
    private var objectDetector: ObjectDetection?
    
    public static func register(with registrar: any FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "DocumentDetection_MethodChannel", binaryMessenger: registrar.messenger())
        let instance = FlutterDocumentDetection()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        objectDetector = try ObjectDetection.Builder().setModelType(modelType: .MOBILENET_SSD).build()
        edgeDetector = try EdgeDetection.Builder().setModelType(modelType: EdgeDetectionModelType.SKSEG)
            .build()
        faceDetector = FaceDetection.Builder()
            .setFaceSize(faceSize: 0.05)
            .setModelType(modelType: FaceDetectionModelType.GOOGLE)
            .build()
        result(true)
    }
    
    private func setWhiteList(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let args = call.arguments as! [String]
        objectDetector?.setWhiteList(whiteList: args.map { e in
            return StringToObjectDetectionObjectTypeMapping[e]!
        })
        result(true)
    }
    
    private func dispose(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        if (self.objectDetector != nil) {
            self.objectDetector = nil
        }
        
        if (self.edgeDetector != nil) {
            self.edgeDetector = nil
        }
        
        if (self.faceDetector != nil) {
            self.faceDetector = nil
        }
        result(true)
    }
    
    public func detect(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let imageBytes = call.arguments as! FlutterStandardTypedData
        let tImg = UIImage(data:Data(imageBytes.data))
        var tImgCG: CGImage = tImg!.cgImage!
        
        if (tImg?.imageOrientation == .left) {
            tImgCG = tImgCG.rotate(orienation: .right)!
        } else if (tImg?.imageOrientation == .up) {
            tImgCG = tImgCG.rotate(orienation: .up)!
        } else if (tImg?.imageOrientation == .down) {
            tImgCG = tImgCG.rotate(orienation: .down)!
        } else if (tImg?.imageOrientation == .right) {
            tImgCG = tImgCG.rotate(orienation: .left)!
        }
        
        let image = UIImage(cgImage: tImgCG)

        let detections = self.objectDetector!.detect(image: image.cgImage!)
        if detections == nil || detections?.count ?? 0 <= 0 {
            result([])
        }
        
        var results: [DocumentScannerResult] = []
        
        
        for detection in detections! {
            let documentEdge = edgeDetector!.detect(image: image.cgImage!)
            if documentEdge == nil {
                continue
            }
            
            let corners: [Float] = [
                documentEdge!.topLeft.x,
                documentEdge!.topLeft.y,
                documentEdge!.topRight.x,
                documentEdge!.topRight.y,
                documentEdge!.bottomRight.x,
                documentEdge!.bottomRight.y,
                documentEdge!.bottomLeft.x,
                documentEdge!.bottomLeft.y,
            ]
            
            let fullImageUI = UIImage(cgImage: image.cgImage!)
            
            let warpedImage = OpenCVWrapper.warpImage(fullImageUI, corners)
                        
            var faceImage: UIImage?
            
            if DOCUMENTS_WITH_FACE.contains(detection.objectType) {
                let faces: [FaceDetectionResult]? = faceDetector!.detect(image: warpedImage)
                
                if !(faces == nil || faces?.count == 0) {
                    let face = faces![0]
                    faceImage = UIImage(
                        cgImage: ImageUtils.cropBoundingBox(
                            image: warpedImage.cgImage!,
                            bbox: face.bbox,
                            scale: 1.4
                        )
                    )
                }
            }
            
            results.append(DocumentScannerResult(
                documentType: detection.objectType,
                documentGroup: ObjectDetectionObjectTypeToObjectGroupMapping["\(detection.objectType)"]!,
                fullImage: fullImageUI,
                documentImage: warpedImage,
                faceImage: faceImage
            ))
        }
        
        result(results.map{e in
            return e.toFlutterMap()
        })
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
        case "setWhiteList":
            do {
                try self.setWhiteList(call: call, result: result)
            } catch {
                result(FlutterError(code: "setWhiteList Error", message: nil, details: nil))
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
