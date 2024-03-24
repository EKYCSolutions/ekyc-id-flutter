import 'dart:typed_data';

import '../core/models/frame_status.dart';
import 'liveness_detection_controller.dart';

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

class LivenessDetectionOptions {
  /// Duration in seconds for user to complete a prompt.
  final int promptTimerCountDownSec;

  /// List of prompts for the user to complete.
  final List<LivenessPromptType> prompts;

  const LivenessDetectionOptions({
    this.promptTimerCountDownSec = 5,
    this.prompts = const [
      LivenessPromptType.LOOK_LEFT,
      LivenessPromptType.LOOK_RIGHT,
      LivenessPromptType.BLINKING
    ],
  });

  Map<String, dynamic> toMap() {
    return {
      "promptTimerCountDownSec": promptTimerCountDownSec,
      "prompts": this.prompts.map((e) {
        var s = e.toString();
        return s.substring(s.indexOf(".") + 1);
      }).toList()
    };
  }
}

class LivenessDetectionResult {
  /// The front face of the user
  late LivenessFace? frontFace;

  /// The front right of the user
  late LivenessFace? rightFace;

  /// The front left of the user
  late LivenessFace? leftFace;

  /// List of prompts that the user has encountered
  late List<LivenessPrompt> prompts;

  LivenessDetectionResult({
    this.frontFace,
    this.rightFace,
    this.leftFace,
  });

  /// Creates an instance of LivenessDetectionResult from a [json] response.
  LivenessDetectionResult.fromMap(Map<String, dynamic> json) {
    if (json["frontFace"] != null) {
      this.frontFace =
          LivenessFace.fromMap(Map<String, dynamic>.from(json["frontFace"]));
    } else {
      this.frontFace = null;
    }

    if (json["rightFace"] != null) {
      this.rightFace =
          LivenessFace.fromMap(Map<String, dynamic>.from(json["rightFace"]));
    } else {
      this.rightFace = null;
    }

    if (json["leftFace"] != null) {
      this.leftFace =
          LivenessFace.fromMap(Map<String, dynamic>.from(json["leftFace"]));
    } else {
      this.leftFace = null;
    }

    this.prompts = List.from(json["prompts"]).map<LivenessPrompt>((e) {
      return LivenessPrompt.fromMap(Map<String, dynamic>.from(e));
    }).toList();
  }
}

/// Class representing the face detection by the liveness detection camera.
class LivenessFace {
  /// The face image
  late Uint8List image;

  /// The probability that the left eye is open
  late double? leftEyeOpenProbability;

  /// The probability that the right eye is open
  late double? rightEyeOpenProbability;

  /// The head angle in the X direction
  late double? headEulerAngleX;

  /// The head angle in the Y direction
  late double? headEulerAngleY;

  /// The head angle in the Z direction
  late double? headEulerAngleZ;

  /// The head direction
  late FaceDetectionHeadDirection? headDirection;

  /// The eye status
  late FaceDetectionEyesStatus? eyesStatus;

  /// Creates an instance of LivenessFace from a [json] response.
  LivenessFace.fromMap(Map<String, dynamic> json) {
    this.image = Uint8List.fromList(json["image"]);
    this.leftEyeOpenProbability = json["leftEyeOpenProbability"];
    this.rightEyeOpenProbability = json["rightEyeOpenProbability"];
    this.headEulerAngleX = json["headEulerAngleX"];
    this.headEulerAngleY = json["headEulerAngleY"];
    this.headEulerAngleZ = json["headEulerAngleZ"];

    if (json["headDirection"] != null) {
      FaceDetectionHeadDirection d = FaceDetectionHeadDirection.values
          .firstWhere((e) =>
              e.toString() ==
              "FaceDetectionHeadDirection.${json['headDirection']}");
      this.headDirection = d;
    } else {
      this.headDirection = null;
    }

    if (json["eyesStatus"] != null) {
      FaceDetectionEyesStatus d = FaceDetectionEyesStatus.values.firstWhere(
          (e) =>
              e.toString() == "FaceDetectionEyesStatus.${json['eyesStatus']}");
      this.eyesStatus = d;
    } else {
      this.eyesStatus = null;
    }
  }
}

/// Class representing the liveness prompt that the user encounters.
class LivenessPrompt {
  /// The liveness prompt type
  late LivenessPromptType prompt;

  /// Boolean indicate if the user successfully completed the prompt.
  late bool? success;

  LivenessPrompt({
    required this.prompt,
    this.success,
  });

  /// Creates an instance of LivenessPrompt from a [json] response.
  LivenessPrompt.fromMap(Map<String, dynamic> json) {
    LivenessPromptType prompt = LivenessPromptType.values.firstWhere(
        (e) => e.toString() == "LivenessPromptType.${json['prompt']}");
    this.prompt = prompt;
    this.success = json["success"];
  }
}
