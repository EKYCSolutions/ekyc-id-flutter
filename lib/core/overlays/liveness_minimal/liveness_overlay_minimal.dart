import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ekyc_id_flutter/core/language.dart';
import 'package:ekyc_id_flutter/core/models/language.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:ekyc_id_flutter/core/models/frame_status.dart';
import 'package:ekyc_id_flutter/core/liveness_detection/liveness_detection_values.dart';

import 'face_cutout.dart';
import 'scanner_message.dart';
import 'timer_countdown.dart';

class LivenessOverlayMinimal extends StatelessWidget {
  const LivenessOverlayMinimal({
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
    final mq = MediaQuery.of(context);
    double cutOutSize = max(120, mq.size.width * 0.9);
    double promptBottom = (mq.size.height / 2) + (cutOutSize / 2) + 30;
    double messageTop = (mq.size.height / 2) + (cutOutSize / 2) + 50;

    Map<LivenessPromptType, Widget> promptIcons = {
      LivenessPromptType.LOOK_LEFT: Icon(
        AntDesign.arrowleft,
        size: 24,
      ),
      LivenessPromptType.LOOK_RIGHT: Icon(
        AntDesign.arrowright,
        size: 24,
      ),
      LivenessPromptType.BLINKING: Icon(
        AntDesign.eye,
        size: 24,
      ),
    };

    return Stack(
      children: [
        Positioned.fill(
          child: FaceCutOut(
            progress: progress,
            isFocusing: isFocusing,
            cutOutSize: cutOutSize,
          ),
        ),
        Positioned(
          bottom: promptBottom,
          left: 0,
          right: 0,
          child: Center(
            child: activePrompt != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        LANGUAGE[activePrompt
                            .toString()
                            .replaceAll("LivenessPromptType.", "")
                            .toLowerCase()]![language]!,
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                      SizedBox(height: 10),
                      promptIcons[activePrompt]!,
                      SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: Offset(0, -2),
                            child: Icon(
                              MaterialIcons.timer,
                              color: Theme.of(context).colorScheme.onBackground,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "${promptTimer}s",
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                          )
                        ],
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: 100,
                        child: TimerCountDown(
                          max: promptCountDownMax,
                          current: promptTimer,
                        ),
                      ),
                    ],
                  )
                : Material(),
          ),
        ),
        Positioned(
          top: messageTop,
          left: 0,
          right: 0,
          child: Center(
            child: ScannerMessage(
              language: language,
              frameStatus: frameStatus,
            ),
          ),
        ),
      ],
    );
  }
}
