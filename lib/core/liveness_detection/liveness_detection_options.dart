import 'liveness_detection_values.dart';

class LivenessDetectionOptions {
  /// Duration in seconds for user to complete a prompt.
  final int promptTimerCountDownSec;

  const LivenessDetectionOptions({
    this.promptTimerCountDownSec = 5,
  });

  Map<String, dynamic> toMap() {
    return {
      "promptTimerCountDownSec": promptTimerCountDownSec,
    };
  }
}
