import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_beep/flutter_beep.dart';

import 'package:ekyc_id_flutter/src/models/language.dart';
import 'package:ekyc_id_flutter/src/document_scanner/document_scanner_values.dart';

import '../core/models/frame_status.dart';
import 'document_scanner.dart';
import 'document_scanner_controller.dart';

/// The Camera View for Document Scanning
class DocumentScannerView extends StatefulWidget {
  const DocumentScannerView({
    Key? key,
    required this.onDocumentScanned,
    this.options = const DocumentScannerOptions(),
    this.language = Language.EN,
    this.overlayBuilder,
    this.fullScreen = true,
  }) : super(key: key);

  /// The language for the audio and text in the DocumentScannerView.
  final Language language;

  /// The option for the DocumentScanner
  final DocumentScannerOptions options;

  /// The callback for when the document scanning process is completed.
  final Future<void> Function(DocumentScannerResult, DocumentScannerResult?)
      onDocumentScanned;

  final Widget Function(BuildContext, FrameStatus, DocumentSide, int)?
      overlayBuilder;

  final bool fullScreen;

  @override
  State<DocumentScannerView> createState() => DocumentScannerViewState();
}

class DocumentScannerViewState extends State<DocumentScannerView> {
  AudioPlayer? player;
  bool shouldRenderCamera = false;
  bool showFlippingAnimation = false;
  bool allowFrameStatusUpdate = true;

  late DocumentScannerController controller;
  int countDown = 0;
  DocumentSide currentSide = DocumentSide.MAIN;
  FrameStatus frameStatus = FrameStatus.INITIALIZING;

  DocumentScannerResult? mainSide;
  DocumentScannerResult? secondarySide;

  Future<void> onPlatformViewCreated(
    DocumentScannerController controller,
  ) async {
    this.controller = controller;
    await this.start();
  }

  Future<void> start() async {
    await this.controller.start(
          options: widget.options,
          onInitialized: onInitialized,
          onDocumentScanned: onDocumentScanned,
          onFrameStatusChanged: onFrameStatusChanged,
          onCurrentSideChanged: onCurrentSideChanged,
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
    this.controller.dispose();
    super.dispose();
  }

  Future<void> onDocumentScanned(DocumentScannerResult mainSide,
      DocumentScannerResult? secondarySide) async {
    try {
      await widget.onDocumentScanned(mainSide, secondarySide);
    } catch (e) {
      print(e);
    } finally {
      this.controller.reset();
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

  void onCurrentSideChanged(DocumentSide side) {
    if (mounted) {
      setState(() {
        currentSide = side;
      });
      playBeep();
      playInstruction();
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

  void playInstruction() {
    String source = "packages/ekyc_id_flutter/assets";
    String side = "scan_${currentSide == DocumentSide.MAIN ? "front" : "back"}";
    String language = widget.language == Language.KH ? "kh" : "en";
    try {
      player?.setAsset("$source/${side}_$language.mp3").then((value) {
        player?.play();
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: shouldRenderCamera
              ? DocumentScanner(
                  onCreated: onPlatformViewCreated,
                )
              : Container(),
        ),
        if (widget.overlayBuilder != null)
          Positioned.fill(
            child: widget.overlayBuilder!(
              context,
              frameStatus,
              currentSide,
              countDown,
            ),
          ),
      ],
    );
  }
}
