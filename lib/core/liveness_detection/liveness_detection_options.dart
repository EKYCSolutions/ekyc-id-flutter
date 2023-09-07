import 'liveness_detection_values.dart';

class LivenessDetectionOptions {
  /// Duration in seconds for user to complete a prompt.
  final int promptTimerCountDownSec;
  final List<LivenessPromptType> prompts;

  const LivenessDetectionOptions({
    this.promptTimerCountDownSec = 5,
    this.prompts = const [
      LivenessPromptType.LOOK_LEFT,
      LivenessPromptType.LOOK_RIGHT,
      LivenessPromptType.BLINKING,
    ],
  });

  Map<String, dynamic> toMap() {
    return {
      "promptTimerCountDownSec": promptTimerCountDownSec,
      "prompts": prompts.map((e) => e.index).toList(),
    };
  }
}
