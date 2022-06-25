import 'dart:typed_data';

import 'package:ekyc_id_flutter/core/models/frame_status.dart';

import 'liveness_detection_controller.dart';

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

class LivenessPrompt {
  late LivenessPromptType prompt;
  late bool? success;

  LivenessPrompt({
    required this.prompt,
    this.success,
  });

  LivenessPrompt.fromMap(Map<String, dynamic> json) {
    LivenessPromptType prompt = LivenessPromptType.values.firstWhere(
        (e) => e.toString() == "LivenessPromptType.${json['prompt']}");
    this.prompt = prompt;
    this.success = json["success"];
  }
}

class LivenessDetectionOptions {
  late int promptTimerCountDownSec;
  late List<LivenessPromptType> prompts;

  LivenessDetectionOptions({
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

class LivenessFace {
  late Uint8List image;
  late double? leftEyeOpenProbability;
  late double? rightEyeOpenProbability;
  late double? headEulerAngleX;
  late double? headEulerAngleY;
  late double? headEulerAngleZ;
  late FaceDetectionHeadDirection? headDirection;
  late FaceDetectionEyesStatus? eyesStatus;

  LivenessFace.fromMap(Map<String, dynamic> json) {
    this.image = Uint8List.fromList(json["image"]);
    this.leftEyeOpenProbability = json["leftEyeOpenProbability"];
    this.rightEyeOpenProbability = json["rightEyeOpenProbability"];
    this.headEulerAngleX = json["headEulerAngleX"];
    this.headEulerAngleY = json["headEulerAngleY"];
    this.headEulerAngleZ = json["headEulerAngleZ"];
    print("FaceDetectionHeadDirection.${json['headDirection']}");
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
      print("FaceDetectionEyesStatus.${json['eyesStatus']!}");
      FaceDetectionEyesStatus d = FaceDetectionEyesStatus.values.firstWhere(
          (e) =>
              e.toString() == "FaceDetectionEyesStatus.${json['eyesStatus']}");
      this.eyesStatus = d;
    } else {
      this.eyesStatus = null;
    }
  }
}

class LivenessDetectionResult {
  late LivenessFace? frontFace;
  late LivenessFace? rightFace;
  late LivenessFace? leftFace;
  late List<LivenessPrompt> prompts;

  LivenessDetectionResult({
    this.frontFace,
    this.rightFace,
    this.leftFace,
  });

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
