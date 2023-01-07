import 'package:ekyc_id_flutter/core/models/frame_status.dart';

import 'liveness_detection_controller.dart';
import 'liveness_detection_result.dart';

typedef void LivenessDetectionOnLivenessTestCompletedCallback(
    LivenessDetectionResult result);

typedef void LivenessDetectionOnFrameStatusChangedCallback(
  FrameStatus frameStatus,
);

typedef void LivenessDetectionOnProgressChangedCallback(
  double progress,
);

typedef void LivenessDetectionOnFocusChangedCallback(
  bool isFocusing,
);

typedef void LivenessDetectionOnActivePromptChangedCallback(
  LivenessPromptType activePrompt,
);

/// Callback for when LivenessDetection native view is created.
typedef void LivenessDetectionCreatedCallback(
  LivenessDetectionController controller,
);



/// Callback for when the count down changed.
typedef void LivenessDetectionOnCountDownChangedCallback({
  required int current,
  required int max,
});

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
