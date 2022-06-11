import 'package:ekyc_id_flutter/models/frame_status.dart';
import 'package:flutter/services.dart';

import 'liveness_detection_values.dart';

class LivenessDetectionController {
  late MethodChannel _methodChannel;
  late EventChannel _eventChannel;

  LivenessDetectionController(int id) {
    _methodChannel = new MethodChannel('LivenessDetection_MethodChannel_$id');
    _eventChannel = new EventChannel('LivenessDetection_EventChannel_$id');
  }

  Future<void> start({
    required LivenessDetectionOnFocusCallback onFocus,
    required LivenessDetectionOnFrameCallback onFrame,
    required LivenessDetectionOnInitializedCallback onInitialized,
    required LivenessDetectionOnFocusDroppedCallback onFocusDropped,
    required LivenessDetectionOnPromptCompletedCallback onPromptCompleted,
    required LivenessDetectionOnAllPromptsCompletedCallback
        onAllPromptsCompleted,
  }) async {
    await _methodChannel.invokeMethod('start');
    registerEventListener(
      onFocus: onFocus,
      onFrame: onFrame,
      onInitialized: onInitialized,
      onFocusDropped: onFocusDropped,
      onPromptCompleted: onPromptCompleted,
      onAllPromptsCompleted: onAllPromptsCompleted,
    );
  }

  Future<void> stop() async {
    await _methodChannel.invokeMethod('stop');
  }

  Future<void> nextImage() async {
    await _methodChannel.invokeMethod('nextImage');
  }

  void registerEventListener({
    required LivenessDetectionOnFocusCallback onFocus,
    required LivenessDetectionOnFrameCallback onFrame,
    required LivenessDetectionOnInitializedCallback onInitialized,
    required LivenessDetectionOnFocusDroppedCallback onFocusDropped,
    required LivenessDetectionOnPromptCompletedCallback onPromptCompleted,
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
        Map<String, dynamic> values =
            Map<String, dynamic>.from(event["values"]);
        onPromptCompleted(
          currentPromptIndex: values["currentPromptIndex"],
          progress: values["progress"],
          success: values["success"],
        );
      } else if (event["type"] == "onAllPromptsCompleted") {
        Map<String, dynamic> values =
            Map<String, dynamic>.from(event["values"]);
        LivenessDetectionResult result =
            LivenessDetectionResult.fromMap(values);
        onAllPromptsCompleted(result);
      }
    });
  }
}
