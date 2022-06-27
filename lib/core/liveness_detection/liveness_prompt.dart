import 'liveness_detection_values.dart';

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
