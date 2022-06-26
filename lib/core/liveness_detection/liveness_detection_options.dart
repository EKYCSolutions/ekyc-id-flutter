import 'liveness_detection_values.dart';

class LivenessDetectionOptions {
  final int promptTimerCountDownSec;
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
