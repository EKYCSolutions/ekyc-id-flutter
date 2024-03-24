import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_beep/flutter_beep.dart';

import 'package:ekyc_id_flutter/src/models/language.dart';

import '../core/models/frame_status.dart';
import '../liveness_detection/liveness_detection_values.dart';
import 'face_scanner.dart';
import 'face_scanner_values.dart';
import 'face_scanner_controller.dart';

/// The Camera View for Document Scanning
class FaceScannerView extends StatefulWidget {
  const FaceScannerView({
    Key? key,
    required this.onFaceScanned,
    this.options = const FaceScannerOptions(),
    this.language = Language.EN,
    this.cameraPlaceholder,
    this.overlayBuilder,
    this.fullScreen = true,
  }) : super(key: key);

  /// The language for the audio and text in the DocumentScannerView.
  final Language language;

  /// The option for the DocumentScanner
  final FaceScannerOptions options;

  /// The callback for when the document scanning process is completed.
  final Future<void> Function(LivenessFace) onFaceScanned;

  final bool fullScreen;
  final Widget? cameraPlaceholder;
  final Widget Function(BuildContext, FrameStatus, int)? overlayBuilder;

  @override
  State<FaceScannerView> createState() => FaceScannerViewState();
}

class FaceScannerViewState extends State<FaceScannerView> {
  AudioPlayer? player;
  //
  int countDown = 0;
  bool shouldRenderCamera = false;
  bool allowFrameStatusUpdate = true;

  late FaceScannerController controller;
  FrameStatus frameStatus = FrameStatus.INITIALIZING;

  Future<void> onPlatformViewCreated(
    FaceScannerController controller,
  ) async {
    this.controller = controller;
    await start();
  }

  Future<void> start() async {
    await this.controller.start(
          options: widget.options,
          onInitialized: onInitialized,
          onFaceScanned: onFaceScanned,
          onFrameStatusChanged: onFrameStatusChanged,
          onCaptureCountDownChanged: onCaptureCountDownChanged,
        );
  }

  Future<void> pause() async {
    this.controller.dispose();
  }

  @override
  void initState() {
    player = AudioPlayer();

    if (widget.fullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        shouldRenderCamera = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    this.player?.dispose();
    this.controller?.dispose();
    super.dispose();
  }

  Future<void> onFaceScanned(LivenessFace face) async {
    try {
      await widget.onFaceScanned(face);
    } catch (e) {
      print(e);
    } finally {
      this.controller.nextImage();
    }
  }

  void onInitialized() {
    playBeep();
    playInstruction();
  }

  void onFrameStatusChanged(FrameStatus f) {
    if (mounted) {
      setState(() {
        frameStatus = f;
      });
    }
  }

  void onCaptureCountDownChanged(int current, int max) {
    if (mounted) {
      setState(() {
        countDown = current;
      });
    }
  }

  void playBeep() {
    try {
      FlutterBeep.beep();
      Vibration.hasVibrator().then((value) {
        if (value != null && value) {
          Vibration.vibrate();
        }
      });
    } catch (e) {}
  }

  void playInstruction() {}

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: shouldRenderCamera
              ? FaceScanner(onCreated: onPlatformViewCreated)
              : widget.cameraPlaceholder ?? Container(),
        ),
        if (widget.overlayBuilder != null)
          Positioned.fill(
              child: widget.overlayBuilder!(context, frameStatus, countDown)),
      ],
    );
  }
}
