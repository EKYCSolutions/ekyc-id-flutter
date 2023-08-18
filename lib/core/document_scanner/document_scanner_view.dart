import 'package:ekyc_id_flutter/core/overlays/document_scanner_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ekyc_id_flutter/core/models/frame_status.dart';
import 'package:ekyc_id_flutter/core/models/language.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_values.dart';

import 'document_scanner.dart';
import 'document_scanner_result.dart';
import 'document_scanner_options.dart';
import 'document_scanner_controller.dart';

/// The Camera View for Document Scanning
class DocumentScannerView extends StatefulWidget {
  const DocumentScannerView({
    Key? key,
    required this.onDocumentScanned,
    this.language = Language.EN,
    this.options = const DocumentScannerOptions(
      preparingDuration: 1,
      scannableDocuments: [
        ScannableDocument(
            mainSide: ObjectDetectionObjectType.NATIONAL_ID_0,
            secondarySide: ObjectDetectionObjectType.NATIONAL_ID_0_BACK)
      ],
    ),
  }) : super(key: key);

  /// The language for the audio and text in the DocumentScannerView.
  final Language language;

  /// The option for the DocumentScanner
  final DocumentScannerOptions options;

  /// The list of document types allowed for scanning.

  /// The callback for when the document scanning process is completed.
  final OnDocumentScannedCallback onDocumentScanned;

  @override
  State<DocumentScannerView> createState() => _DocumentScannerViewState();
}

class _DocumentScannerViewState extends State<DocumentScannerView> {
  bool shouldRenderCamera = false;
  bool showFlippingAnimation = false;
  bool allowFrameStatusUpdate = true;

  late DocumentScannerController controller;
  DocumentSide currentSide = DocumentSide.MAIN;
  FrameStatus frameStatus = FrameStatus.INITIALIZING;
  List<ObjectDetectionObjectGroup> mainWhiteList = [];
  List<ObjectDetectionObjectGroup> secondaryWhiteList = [];

  DocumentScannerResult? mainSide;
  DocumentScannerResult? secondarySide;

  Future<void> onPlatformViewCreated(
    DocumentScannerController controller,
  ) async {
    this.controller = controller;
    await this.controller.start(
          onFrameStatusChanged: onFrameStatusChanged,
          onCurrentSideChanged: onCurrentSideChanged,
          onDocumentScanned: onDocumentScanned,
          options: widget.options,
          language: widget.language,
        );
  }

  void onFrameStatusChanged(FrameStatus f) {
    if (mounted) {
      setState(() {
        frameStatus = f;
      });
    }
    if (mounted &&
        f == FrameStatus.PROCESSING &&
        currentSide == DocumentSide.SECONDARY) {
      setState(() {
        showFlippingAnimation = false;
      });
    }
    if (mounted &&
        f == FrameStatus.DOCUMENT_NOT_FOUND &&
        currentSide == DocumentSide.SECONDARY) {
      setState(() {
        showFlippingAnimation = true;
      });
    }
  }

  void onCurrentSideChanged(DocumentSide documentSide) {
    if (mounted) {
      setState(() {
        currentSide = documentSide;
      });
    }
  }

  void onDocumentScanned(
    DocumentScannerResult mainSide,
    DocumentScannerResult? secondarySide,
  ) async {
    await widget.onDocumentScanned(
        mainSide: mainSide, secondarySide: secondarySide);
  }

  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    this.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          // top: 0,
          // left: 0,
          // right: 100,
          // bottom: 100,
          child: DocumentScanner(
            onCreated: onPlatformViewCreated,
          ),
        ),
        Positioned.fill(
          child: DocumentScannerOverlay(
            frameStatus: frameStatus,
            currentSide: currentSide,
            language: widget.language,
            showFlippingAnimation: showFlippingAnimation,
          ),
        )
      ],
    );
  }
}
