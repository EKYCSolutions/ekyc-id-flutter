import 'dart:typed_data';

import 'package:ekyc_id_flutter/models/frame_status.dart';

import 'liveness_detection_controller.dart';

typedef void LivenessDetectionCreatedCallback(
  LivenessDetectionController controller,
);

typedef void LivenessDetectionOnFrameCallback(FrameStatus frameStatus);

typedef void LivenessDetectionOnAllPromptsCompletedCallback(
    LivenessDetectionResult result);

typedef void LivenessDetectionOnPromptCompletedCallback({
  required LivenessPrompt currentPrompt,
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

class LivenessDetectionResult {
  late Uint8List? frontFace;
  late Uint8List? rightFace;
  late Uint8List? leftFace;
  late List<LivenessPrompt> prompts;

  LivenessDetectionResult({
    this.frontFace,
    this.rightFace,
    this.leftFace,
  });

  LivenessDetectionResult.fromMap(Map<String, dynamic> json) {
    if (json["frontFace"] != null) {
      this.frontFace = Uint8List.fromList(json["frontFace"]);
    }
    if (json["rightFace"] != null) {
      this.rightFace = Uint8List.fromList(json["rightFace"]);
    }
    if (json["leftFace"] != null) {
      this.leftFace = Uint8List.fromList(json["leftFace"]);
    }

    this.prompts = List.from(json["prompts"]).map<LivenessPrompt>((e) {
      return LivenessPrompt.fromMap(Map<String, dynamic>.from(e));
    }).toList();
  }
}
