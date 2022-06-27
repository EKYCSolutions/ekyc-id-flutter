import 'dart:async';

import 'package:ekyc_id_flutter/core/models/language.dart';
import 'package:ekyc_id_flutter/core/models/frame_status.dart';
import 'package:ekyc_id_flutter/core/liveness_detection/liveness_detection.dart';
import 'package:ekyc_id_flutter/core/overlays/liveness_detection_overlay.dart';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:just_audio/just_audio.dart';

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
    this.options = const LivenessDetectionOptions(
      promptTimerCountDownSec: 5,
      prompts: [
        LivenessPromptType.LOOK_LEFT,
        LivenessPromptType.LOOK_RIGHT,
        LivenessPromptType.BLINKING
      ],
    ),
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
  AudioPlayer? player;
  bool hasFailed = false;
  bool isFocusing = false;

  int promptTimer = 0;
  int? activePromptIndex;

  late LivenessDetectionOptions options;

  LivenessPrompt? prompt;
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
          options: options,
          onFocus: onFocus,
          onFrame: onFrame,
          onInitialized: onInitialized,
          onFocusDropped: onFocusDropped,
          onPromptCompleted: onPromptCompleted,
          onCountDownChanged: onCountDownChanged,
          onAllPromptsCompleted: onAllPromptsCompleted,
        );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      options = widget.options;
    });
    player = AudioPlayer();
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
    this.player?.dispose();
    this.controller.dispose();
    this.progressController.dispose();
    super.dispose();
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

  void onPromptCompleted({
    required int completedPromptIndex,
    required bool success,
    required double progress,
  }) {
    if (this.mounted) {
      vibrate();

      setState(() {
        activePromptIndex = activePromptIndex! + 1;
      });

      playInstruction();

      progressController.animateTo(progress).then((value) {
        this.controller.nextImage();
      });
    }
  }

  void onFocus() {
    if (this.mounted) {
      setState(() {
        activePromptIndex = 0;
        isFocusing = true;
      });

      playInstruction();
    }
  }

  void onFocusDropped() {
    if (this.mounted) {
      progressController.value = 0;

      setState(() {
        activePromptIndex = null;
        isFocusing = false;
      });
    }
  }

  void onAllPromptsCompleted(LivenessDetectionResult result) {
    if (this.mounted) {
      vibrate();

      progressController.animateTo(1).then((value) {
        widget.onLivenessTestCompleted(result).then((value) {
          progressController.value = 0;
          this.controller.nextImage();
        });
      });
    }
  }

  void onFrame(FrameStatus f) {
    if (this.mounted) {
      setState(() {
        frameStatus = f;
      });
    }
  }

  void onInitialized() {}

  void playInstruction() {
    String? type;
    if (options.prompts[activePromptIndex!] == LivenessPromptType.BLINKING) {
      type = "blink";
    } else if (options.prompts[activePromptIndex!] ==
        LivenessPromptType.LOOK_LEFT) {
      type = "look_left";
    } else if (options.prompts[activePromptIndex!] ==
        LivenessPromptType.LOOK_RIGHT) {
      type = "look_right";
    }

    if (type != null) {
      String source = "packages/ekyc_id_flutter/assets";
      String language = widget.language == Language.KH ? "kh" : "en";
      try {
        player?.setAsset("$source/${type}_$language.mp3").then((value) {
          player?.play();
        });
      } catch (e) {
        print(e);
      }
    }
  }

  void vibrate() {
    Vibration.hasVibrator().then((value) {
      if (value != null && value) {
        Vibration.vibrate();
      }
    });
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
            activePrompt: activePromptIndex != null
                ? options.prompts[activePromptIndex!]
                : null,
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
