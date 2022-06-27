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
    required LivenessDetectionOnFocusCallback onFocus,
    required LivenessDetectionOnFrameCallback onFrame,
    required LivenessDetectionOnInitializedCallback onInitialized,
    required LivenessDetectionOnFocusDroppedCallback onFocusDropped,
    required LivenessDetectionOnPromptCompletedCallback onPromptCompleted,
    required LivenessDetectionOnCountDownChangedCallback onCountDownChanged,
    required LivenessDetectionOnAllPromptsCompletedCallback
        onAllPromptsCompleted,
    required LivenessDetectionOptions options,
  }) async {
    await _methodChannel.invokeMethod('start', options.toMap());

    _registerEventListener(
      onFocus: onFocus,
      onFrame: onFrame,
      onInitialized: onInitialized,
      onFocusDropped: onFocusDropped,
      onPromptCompleted: onPromptCompleted,
      onCountDownChanged: onCountDownChanged,
      onAllPromptsCompleted: onAllPromptsCompleted,
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
    required LivenessDetectionOnFocusCallback onFocus,
    required LivenessDetectionOnFrameCallback onFrame,
    required LivenessDetectionOnInitializedCallback onInitialized,
    required LivenessDetectionOnFocusDroppedCallback onFocusDropped,
    required LivenessDetectionOnPromptCompletedCallback onPromptCompleted,
    required LivenessDetectionOnCountDownChangedCallback onCountDownChanged,
    required LivenessDetectionOnAllPromptsCompletedCallback
        onAllPromptsCompleted,
  }) {
    _eventChannel.receiveBroadcastStream().listen((event) async {
      if (event["type"] == "onFocus") {
        onFocus();
      } else if (event["type"] == "onFrame") {
        FrameStatus frameStatus = FrameStatus.values.firstWhere(
            (e) => e.toString() == "FrameStatus.${event['values']}");
        onFrame(frameStatus);
      } else if (event["type"] == "onInitialized") {
        onInitialized();
      } else if (event["type"] == "onFocusDropped") {
        onFocusDropped();
      } else if (event["type"] == "onPromptCompleted") {
        print(event);
        Map<String, dynamic> values =
            Map<String, dynamic>.from(event["values"]);
        onPromptCompleted(
          completedPromptIndex: values["completedPromptIndex"],
          success: values["success"],
          progress: values["progress"],
        );
      } else if (event["type"] == "onAllPromptsCompleted") {
        Map<String, dynamic> values = Map<String, dynamic>.from(
          event["values"],
        );
        LivenessDetectionResult result =
            LivenessDetectionResult.fromMap(values);
        onAllPromptsCompleted(result);
      } else if (event["type"] == "onCountDownChanged") {
        Map<String, dynamic> values =
            Map<String, dynamic>.from(event["values"]);
        onCountDownChanged(
          current: values["current"],
          max: values["max"],
        );
      }
    });
  }
}
