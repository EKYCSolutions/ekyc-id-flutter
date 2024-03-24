import 'package:flutter/services.dart';

import '../liveness_detection/liveness_detection_values.dart';

/// Class for controlling the document scanner functionalites.
class FaceDetectionController {
  late MethodChannel _methodChannel;

  FaceDetectionController() {
    _methodChannel = new MethodChannel('FaceDetection_MethodChannel');
  }

  Future<List<LivenessFace>> detect(Uint8List image) async {
    List<dynamic> result = await _methodChannel.invokeMethod('detect', image);
    return result
        .map((e) => LivenessFace.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Initializes the camera and starts the scanning process.
  ///
  Future<void> initialize() async {
    await _methodChannel.invokeMethod('initialize');
  }

  /// Stops the scanning process and dispose the camera object.
  Future<void> dispose() async {
    await _methodChannel.invokeMethod('dispose');
  }
}
