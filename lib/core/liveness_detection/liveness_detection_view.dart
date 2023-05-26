import 'dart:async';

import 'package:ekyc_id_flutter/core/models/language.dart';
import 'package:ekyc_id_flutter/core/models/frame_status.dart';
import 'package:ekyc_id_flutter/core/liveness_detection/liveness_detection.dart';
import 'package:ekyc_id_flutter/core/overlays/liveness_detection_overlay.dart';

import 'package:flutter/material.dart';

import 'liveness_prompt.dart';
import 'liveness_detection_values.dart';
import 'liveness_detection_result.dart';
import 'liveness_detection_options.dart';
import 'liveness_detection_controller.dart';

/// The Camera View for Liveness Detection
class LivenessDetectionView extends StatefulWidget {
  LivenessDetectionView({
    Key? key,
    required this.onLivenessTestCompleted,
    this.language = Language.EN,
    this.options =
        const LivenessDetectionOptions(promptTimerCountDownSec: 5, prompts: [
      LivenessPromptType.LOOK_LEFT,
      LivenessPromptType.LOOK_RIGHT,
      LivenessPromptType.BLINKING,
    ]),
  });

  /// The language for the audio and text in the LivenessDetectionView.
  final Language language;

  /// The option for the LivenessDetection
  final LivenessDetectionOptions options;

  /// The callback for when the liveness test is completed.
  final OnLivenessTestCompletedCallback onLivenessTestCompleted;

  @override
  _LivenessDetectionViewState createState() => _LivenessDetectionViewState();
}

class _LivenessDetectionViewState extends State<LivenessDetectionView>
    with SingleTickerProviderStateMixin {
  bool isFocusing = false;

  int promptTimer = 0;

  late LivenessDetectionOptions options;

  LivenessPromptType activePrompt = LivenessPromptType.LOOK_LEFT;
  late LivenessDetectionController controller;
  FrameStatus frameStatus = FrameStatus.INITIALIZING;

  late Animation<double> progress;
  late AnimationController progressController;

  Future<void> onPlatformViewCreated(
    LivenessDetectionController controller,
  ) async {
    this.controller = controller;
    setState(() {
      promptTimer = widget.options.promptTimerCountDownSec;
    });

    await this.controller.start(
          onFocusChanged: onFocusChanged,
          onActivePromptChanged: onActivePromptChanged,
          onCountDownChanged: onCountDownChanged,
          onFrameStatusChanged: onFrameStatusChanged,
          onLivenessTestCompleted: onLivenessCompleted,
          onProgressChanged: onProgressChanged,
          options: options,
          language: widget.language,
        );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      options = widget.options;
    });
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() => setState(() {}));
    progress = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: progressController,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOutQuad),
      ),
    );
  }

  @override
  void dispose() {
    this.controller.dispose();
    this.progressController.dispose();
    super.dispose();
  }

  void onProgressChanged(double progress) {
    print("------------progress value $progress");
    progressController.value = progress;
  }

  void onCountDownChanged({
    required int current,
    required int max,
  }) {
    if (this.mounted) {
      setState(() {
        promptTimer = current;
      });
    }
  }

  void onActivePromptChanged(LivenessPromptType livesnessPromptType) {
    if (this.mounted) {
      setState(() {
        activePrompt = livesnessPromptType;
      });
    }
  }

  void onFocusChanged(bool focusing) {
    if (this.mounted) {
      setState(() {
        isFocusing = focusing;
      });
    }
  }

  void onLivenessCompleted(LivenessDetectionResult result) {
    if (this.mounted) {
      progressController.animateTo(1).then((value) {
        widget.onLivenessTestCompleted(result).then((value) {
          progressController.value = 0;
          this.controller.nextImage();
        });
      });
    }
  }

  void onFrameStatusChanged(FrameStatus f) {
    if (this.mounted) {
      setState(() {
        frameStatus = f;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: LivenessDetection(onCreated: onPlatformViewCreated),
        ),
        Positioned.fill(
          child: LivenessDetectionOverlay(
            promptCountDownMax: options.promptTimerCountDownSec,
            activePrompt: activePrompt,
            progress: progress.value,
            promptTimer: promptTimer,
            isFocusing: isFocusing,
            language: widget.language,
            frameStatus: frameStatus,
          ),
        )
      ],
    );
  }
}
