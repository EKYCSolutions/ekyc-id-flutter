import 'package:ekyc_id_flutter/core/models/frame_status.dart';

import 'liveness_detection_controller.dart';
import 'liveness_detection_result.dart';

/// Callback for when LivenessDetection native view is created.
typedef void LivenessDetectionCreatedCallback(
  LivenessDetectionController controller,
);

/// Callback on every frame during the liveness detection process.
typedef void LivenessDetectionOnFrameCallback(FrameStatus frameStatus);

/// Callback for when all prompts is completed.
typedef void LivenessDetectionOnAllPromptsCompletedCallback(
  LivenessDetectionResult result,
);

/// Callback for when a prompt is completed.
typedef void LivenessDetectionOnPromptCompletedCallback({
  required int completedPromptIndex,
  required bool success,
  required double progress,
});

/// Callback for when the count down changed.
typedef void LivenessDetectionOnCountDownChangedCallback({
  required int current,
  required int max,
});

/// Callback for when liveness detection is initialized.
typedef void LivenessDetectionOnInitializedCallback();

/// Callback for when the liveness detection starts focusing on the user.
typedef void LivenessDetectionOnFocusCallback();

/// Callback for when the liveness detection focus dropped.
typedef void LivenessDetectionOnFocusDroppedCallback();

/// Callback for when the liveness test is completed.
typedef Future<void> OnLivenessTestCompletedCallback(
  LivenessDetectionResult result,
);

/// Enum indicating the liveness prompt type for the user to complete.
enum LivenessPromptType {
  BLINKING,
  LOOK_LEFT,
  LOOK_RIGHT,
}

/// Enum indicating the head direction of the user face.
enum FaceDetectionHeadDirection {
  FRONT,
  LEFT,
  RIGHT,
}

/// Enum indicating the eye status of the user face.
enum FaceDetectionEyesStatus {
  OPEN,
  CLOSED,
}

extension LivenessPromptTypeToString on LivenessPromptType {
  String toShortString() {
    return this.toString().split('.').last;
  }
}
