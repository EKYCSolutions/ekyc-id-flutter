import 'package:flutter/services.dart';

import 'models/object_detection_object_type.dart';
import '../document_scanner/document_scanner_values.dart';

/// Class for controlling the document scanner functionalites.
class DocumentDetectionController {
  late MethodChannel _methodChannel;

  DocumentDetectionController() {
    _methodChannel = new MethodChannel('DocumentDetection_MethodChannel');
  }

  Future<List<DocumentScannerResult>> detect(Uint8List image) async {
    List<dynamic> result = await _methodChannel.invokeMethod('detect', image);
    return result
        .map((e) => DocumentScannerResult.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> initialize() async {
    await _methodChannel.invokeMethod('initialize');
  }

  Future<void> setWhiteList(List<ObjectDetectionObjectType> whiteList) async {
    await _methodChannel.invokeMethod(
        'setWhiteList', whiteList.map((e) => e.toShortString()).toList());
  }

  Future<void> dispose() async {
    await _methodChannel.invokeMethod('dispose');
  }
}
