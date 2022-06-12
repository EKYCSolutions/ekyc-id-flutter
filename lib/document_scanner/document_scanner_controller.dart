import 'package:ekyc_id_flutter/models/frame_status.dart';
import 'package:flutter/services.dart';

import 'document_scanner_values.dart';

class DocumentScannerController {
  late MethodChannel _methodChannel;
  late EventChannel _eventChannel;

  DocumentScannerController(int id) {
    _methodChannel = new MethodChannel('DocumentScanner_MethodChannel_$id');
    _eventChannel = new EventChannel('DocumentScanner_EventChannel_$id');
  }

  Future<void> start({
    required DocumentScannerOnFrameCallback onFrame,
    required DocumentScannerOnDetectionCallback onDetection,
    required DocumentScannerOnInitializedCallback onInitialized,
    List<String>? whiteList,
  }) async {
    await _methodChannel.invokeMethod('start');
    registerEventListener(
      onFrame: onFrame,
      onDetection: onDetection,
      onInitialized: onInitialized,
    );
  }

  Future<void> setTapToFocus() async {
    await _methodChannel.invokeMethod('setTapToFocus');
  }

  Future<void> dispose() async {
    await _methodChannel.invokeMethod('dispose');
  }

  Future<void> nextImage() async {
    await _methodChannel.invokeMethod('nextImage');
  }

  Future<bool?> setWhiteList(List<String>? whiteList) async {
    return _methodChannel.invokeMethod<bool>('setWhiteList', whiteList ?? []);
  }

  void registerEventListener({
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
