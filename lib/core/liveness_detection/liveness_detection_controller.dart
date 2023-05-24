import 'package:ekyc_id_flutter/core/models/frame_status.dart';
import 'package:flutter/services.dart';

import 'liveness_detection_options.dart';
import 'liveness_detection_result.dart';
import 'liveness_detection_values.dart';

class LivenessDetectionController {
  late MethodChannel _methodChannel;
  late EventChannel _eventChannel;

  LivenessDetectionController(int id) {
    _methodChannel = new MethodChannel('LivenessDetection_MethodChannel_$id');
    _eventChannel = new EventChannel('LivenessDetection_EventChannel_$id');
  }

  /// Initializes the camera and starts the scanning process.
  ///
  /// When the camera is initialized [onInitialized] is called.
  /// After the initialization process, the scanning process begins and on every frame [onFrame] is called.
  /// When the camera detects a face in the center of frame, [onFocus] is called.
  /// After the user completed each prompt, [onPromptCompleted] is called.
  Future<void> start({
    required LivenessDetectionOnProgressChangedCallback onProgressChanged,
    required LivenessDetectionOnFocusChangedCallback onFocusChanged,
    required LivenessDetectionOnFrameStatusChangedCallback onFrameStatusChanged,
    required LivenessDetectionOnActivePromptChangedCallback
        onActivePromptChanged,
    required LivenessDetectionOnCountDownChangedCallback onCountDownChanged,
    required LivenessDetectionOnLivenessTestCompletedCallback
        onLivenessTestCompleted,
    required LivenessDetectionOptions options,
  }) async {
    await _methodChannel.invokeMethod('start', options.toMap());
    _registerEventListener(
      onProgressChanged: onProgressChanged,
      onFocusChanged: onFocusChanged,
      onFrameStatusChanged: onFrameStatusChanged,
      onActivePromptChanged: onActivePromptChanged,
      onCountDownChanged: onCountDownChanged,
      onLivenessTestCompleted: onLivenessTestCompleted,
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
    required LivenessDetectionOnProgressChangedCallback onProgressChanged,
    required LivenessDetectionOnFocusChangedCallback onFocusChanged,
    required LivenessDetectionOnFrameStatusChangedCallback onFrameStatusChanged,
    required LivenessDetectionOnActivePromptChangedCallback
        onActivePromptChanged,
    required LivenessDetectionOnCountDownChangedCallback onCountDownChanged,
    required LivenessDetectionOnLivenessTestCompletedCallback
        onLivenessTestCompleted,
  }) {
    _eventChannel.receiveBroadcastStream().listen((event) async {
      if (event["type"] == "onFrameStatusChanged") {
        FrameStatus frameStatus = FrameStatus.values.firstWhere(
            (e) => e.toString() == "FrameStatus.${event['values']}");
        onFrameStatusChanged(frameStatus);
      } else if (event["type"] == "onFocusChanged") {
        onFocusChanged(event["values"]);
      } else if (event["type"] == "onActivePromptChanged") {
        print("condition matched");
        LivenessPromptType livenessPromptType = LivenessPromptType.values
            .firstWhere((e) => e.toString() == "${event['values']}");
        onActivePromptChanged(livenessPromptType);
      } else if (event["type"] == "onLivenessTestCompleted") {
        Map<String, dynamic> values = Map<String, dynamic>.from(
          event["values"],
        );
        LivenessDetectionResult result =
            LivenessDetectionResult.fromMap(values);
        onLivenessTestCompleted(result);
      } else if (event["type"] == "onCountDownChanged") {
        Map<String, dynamic> values =
            Map<String, dynamic>.from(event["values"]);
        onCountDownChanged(
          current: values["current"],
          max: values["max"],
        );
      } else if (event["type"] == "onProgressChanged") {
        onProgressChanged(event["values"] as double);
      }
    });
  }
}
