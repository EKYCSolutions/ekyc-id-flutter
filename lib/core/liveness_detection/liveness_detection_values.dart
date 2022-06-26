import 'package:ekyc_id_flutter/core/models/frame_status.dart';

import 'liveness_detection_controller.dart';
import 'liveness_detection_result.dart';

typedef void LivenessDetectionCreatedCallback(
  LivenessDetectionController controller,
);

typedef void LivenessDetectionOnFrameCallback(FrameStatus frameStatus);

typedef void LivenessDetectionOnAllPromptsCompletedCallback(
    LivenessDetectionResult result);

typedef void LivenessDetectionOnPromptCompletedCallback({
  required int completedPromptIndex,
  required bool success,
  required double progress,
});

typedef void LivenessDetectionOnCountDownChangedCallback({
  required int current,
  required int max,
});

typedef void LivenessDetectionOnInitializedCallback();

typedef void LivenessDetectionOnFocusCallback();

typedef void LivenessDetectionOnFocusDroppedCallback();

typedef Future<void> OnLivenessTestCompletedCallback(
  LivenessDetectionResult result,
);

enum LivenessPromptType {
  BLINKING,
  LOOK_LEFT,
  LOOK_RIGHT,
}

enum FaceDetectionHeadDirection {
  FRONT,
  LEFT,
  RIGHT,
}

enum FaceDetectionEyesStatus {
  OPEN,
  CLOSED,
}

extension LivenessPromptTypeToString on LivenessPromptType {
  String toShortString() {
    return this.toString().split('.').last;
  }
}
