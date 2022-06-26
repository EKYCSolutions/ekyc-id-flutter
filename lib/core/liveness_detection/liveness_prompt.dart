import 'liveness_detection_values.dart';

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
