import 'liveness_face.dart';
import 'liveness_prompt.dart';

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
