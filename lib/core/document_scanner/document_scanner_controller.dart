import 'package:flutter/services.dart';

import 'package:ekyc_id_flutter/core/models/frame_status.dart';

import 'document_scanner_options.dart';
import 'document_scanner_result.dart';
import 'document_scanner_values.dart';

/// Class for controlling the document scanner functionalites.
class DocumentScannerController {
  late MethodChannel _methodChannel;
  late EventChannel _eventChannel;

  DocumentScannerController(int id) {
    _methodChannel = new MethodChannel('DocumentScanner_MethodChannel_$id');
    _eventChannel = new EventChannel('DocumentScanner_EventChannel_$id');
  }

  /// Initializes the camera and starts the scanning process.
  ///
  /// When the camera is initialized [onInitialized] is called.
  /// After the initialization process, the scanning process begins and on every frame [onFrame] is called.
  /// When the camera detects the presence of a valid document, [onDetection] is called.
  Future<void> start({
    required DocumentScannerOnFrameCallback onFrame,
    required DocumentScannerOnDetectionCallback onDetection,
    required DocumentScannerOnInitializedCallback onInitialized,
    required DocumentScannerOptions options,
  }) async {
    await _methodChannel.invokeMethod('start', options.toMap());
    _registerEventListener(
      onFrame: onFrame,
      onDetection: onDetection,
      onInitialized: onInitialized,
    );
  }

  /// Stops the scanning process and dispose the camera object.
  Future<void> dispose() async {
    await _methodChannel.invokeMethod('dispose');
  }

  /// Allows the camera to start processing the next frame.
  Future<void> nextImage() async {
    await _methodChannel.invokeMethod('nextImage');
  }

  /// Sets the type of documents the scanner should detect.
  ///
  /// Each [whiteList] item should be an upper case string of the [ObjectDetectionObjectGroup]
  Future<bool?> setWhiteList(List<String>? whiteList) async {
    return _methodChannel.invokeMethod<bool>('setWhiteList', whiteList ?? []);
  }

  void _registerEventListener({
    required DocumentScannerOnFrameCallback onFrame,
    required DocumentScannerOnDetectionCallback onDetection,
    required DocumentScannerOnInitializedCallback onInitialized,
  }) {
    _eventChannel.receiveBroadcastStream().listen((event) async {
      if (event["type"] == "onDetection") {
        Map<String, dynamic> values =
            Map<String, dynamic>.from(event["values"]);
        DocumentScannerResult result = DocumentScannerResult.fromMap(values);
        onDetection(result);
      } else if (event["type"] == "onFrame") {
        FrameStatus frameStatus = FrameStatus.values.firstWhere(
            (e) => e.toString() == "FrameStatus.${event['values']}");
        onFrame(frameStatus);
      } else if (event["type"] == "onInitialized") {
        onInitialized();
      }
    });
  }
}
