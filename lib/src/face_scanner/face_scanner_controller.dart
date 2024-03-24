import 'package:flutter/services.dart';

import '../core/models/frame_status.dart';
import '../liveness_detection/liveness_detection_values.dart';
import 'face_scanner_values.dart';

/// Class for controlling the document scanner functionalites.
class FaceScannerController {
  late MethodChannel _methodChannel;
  late EventChannel _eventChannel;

  FaceScannerController(int id) {
    _methodChannel = new MethodChannel('FaceScanner_MethodChannel_$id');
    _eventChannel = new EventChannel('FaceScanner_EventChannel_$id');
  }

  /// Initializes the camera and starts the scanning process.
  ///
  Future<void> start({
    required void Function() onInitialized,
    required void Function(FrameStatus) onFrameStatusChanged,
    required Future<void> Function(LivenessFace) onFaceScanned,
    required void Function(int, int) onCaptureCountDownChanged,
    required FaceScannerOptions options,
  }) async {
    await _methodChannel.invokeMethod('start', options.toMap());
    _registerEventListener(
      onInitialized: onInitialized,
      onFaceScanned: onFaceScanned,
      onFrameStatusChanged: onFrameStatusChanged,
      onCaptureCountDownChanged: onCaptureCountDownChanged,
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

  void _registerEventListener({
    required void Function() onInitialized,
    required void Function(FrameStatus) onFrameStatusChanged,
    required Future<void> Function(LivenessFace) onFaceScanned,
    required void Function(int, int) onCaptureCountDownChanged,
  }) {
    _eventChannel.receiveBroadcastStream().listen((event) async {
      if (event["type"] == "onFaceScanned") {
        Map<String, dynamic> values =
            Map<String, dynamic>.from(event["values"]);
        LivenessFace face = LivenessFace.fromMap(values);
        onFaceScanned(face);
        return;
      }

      if (event["type"] == "onInitialized") {
        onInitialized();
        return;
      }

      if (event["type"] == "onFrameStatusChanged") {
        FrameStatus frameStatus = FrameStatus.values.firstWhere(
            (e) => e.toString() == "FrameStatus.${event['values']}");
        onFrameStatusChanged(frameStatus);
        return;
      }

      if (event["type"] == "onCaptureCountDownChanged") {
        onCaptureCountDownChanged(
          event["values"]["current"],
          event["values"]["max"],
        );
        return;
      }
    });
  }
}
