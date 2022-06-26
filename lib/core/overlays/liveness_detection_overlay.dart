import 'package:ekyc_id_flutter/core/liveness_detection/liveness_detection_values.dart';
import 'package:ekyc_id_flutter/core/models/frame_status.dart';
import 'package:ekyc_id_flutter/core/models/language.dart';
import 'package:ekyc_id_flutter/core/overlays/liveness_minimal/liveness_overlay_minimal.dart';
import 'package:flutter/material.dart';

class LivenessDetectionOverlay extends StatelessWidget {
  const LivenessDetectionOverlay({
    Key? key,
    required this.promptCountDownMax,
    this.activePrompt,
    this.progress = 0.0,
    this.promptTimer = 0,
    this.isFocusing = false,
    this.language = Language.EN,
    this.frameStatus = FrameStatus.INITIALIZING,
  }) : super(key: key);

  final int promptTimer;
  final bool isFocusing;
  final double progress;
  final Language language;
  final int promptCountDownMax;
  final FrameStatus frameStatus;
  final LivenessPromptType? activePrompt;

  @override
  Widget build(BuildContext context) {
    return LivenessOverlayMinimal(
      language: language,
      progress: progress,
      isFocusing: isFocusing,
      promptTimer: promptTimer,
      frameStatus: frameStatus,
      activePrompt: activePrompt,
      promptCountDownMax: promptCountDownMax,
    );
  }
}
