import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_options.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_values.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_view.dart';
import 'package:ekyc_id_flutter/core/liveness_detection/liveness_detection_options.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';

import 'core/document_scanner/document_scanner_result.dart';
import 'core/liveness_detection/liveness_detection_result.dart';
import 'core/liveness_detection/liveness_detection_view.dart';
import 'core/models/language.dart';

enum _KYCMode {
  DOCUMENT,
  LIVENESS,
}

/// Callback for when the KYC Process has been completed.
typedef Future<void> OnKYCCompletedCallback({
  required DocumentScannerResult mainSide,
  required LivenessDetectionResult liveness,
  DocumentScannerResult? secondarySide,
});

/// Widget for performing `Document Scanning` and `Liveness Detection` in one go.
class EkycIDExpress extends StatefulWidget {
  const EkycIDExpress({
    Key? key,
    required this.onKYCCompleted,
    this.language = Language.KH,
    this.documentTypes = const [DocumentScannerDocType.NATIONAL_ID],
    this.documentScannerOptions = const DocumentScannerOptions(
      scannableDocuments: [
        ScannableDocument(
          mainSide: ObjectDetectionObjectType.NATIONAL_ID_0,
          secondarySide: ObjectDetectionObjectType.NATIONAL_ID_0_BACK,
        )
      ],
    ),
    this.livenessDetectionOptions = const LivenessDetectionOptions(
      promptTimerCountDownSec: 5,
    ),
  }) : super(key: key);

  /// The language for the audio and text in the EkycIDExpress.
  final Language language;

  /// Callback for the KYC process is completed.
  final OnKYCCompletedCallback onKYCCompleted;

  /// List of document types that are allowed to be scanned.
  final List<DocumentScannerDocType> documentTypes;

  /// The option for the DocumentScanner
  final DocumentScannerOptions documentScannerOptions;

  /// The option for the LivenessDetection
  final LivenessDetectionOptions livenessDetectionOptions;

  @override
  State<EkycIDExpress> createState() => _EkycIDExpressState();
}

class _EkycIDExpressState extends State<EkycIDExpress> {
  _KYCMode mode = _KYCMode.DOCUMENT;
  bool showLivenessCamera = false;
  bool showDocumentCamera = true;

  late DocumentScannerResult mainSide;
  late LivenessDetectionResult liveness;
  DocumentScannerResult? secondarySide;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  void onDocumentCameraAnimationEnds() {
    setState(() {
      showDocumentCamera = mode == _KYCMode.DOCUMENT;
    });
  }

  void onLivenessCameraAnimationEnds() {
    setState(() {
      showLivenessCamera = mode == _KYCMode.LIVENESS;
    });
  }

  Future<void> onDocumentScanned({
    required DocumentScannerResult mainSide,
    DocumentScannerResult? secondarySide,
  }) async {
    setState(() {
      mode = _KYCMode.LIVENESS;
      this.mainSide = mainSide;
      this.secondarySide = secondarySide;
    });
  }

  Future<void> onLivenessTestCompleted(LivenessDetectionResult result) async {
    setState(() {
      liveness = result;
    });

    await widget
        .onKYCCompleted(
      liveness: liveness,
      mainSide: mainSide,
      secondarySide: secondarySide,
    )
        .then((value) async {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        mode = _KYCMode.DOCUMENT;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: Hero(
          tag: "back-button",
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15)),
              child: Center(
                child: Icon(
                  AntDesign.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.linear,
            onEnd: onDocumentCameraAnimationEnds,
            top: 0,
            left: mode == _KYCMode.DOCUMENT ? 0 : -mq.size.width,
            width: mq.size.width,
            height: mq.size.height,
            child: showDocumentCamera
                ? DocumentScannerView(
                    onDocumentScanned: onDocumentScanned,
                    language: widget.language,
                    options: widget.documentScannerOptions,
                  )
                : Container(color: Colors.black),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.linear,
            onEnd: onLivenessCameraAnimationEnds,
            top: 0,
            left: mode == _KYCMode.LIVENESS ? 0 : mq.size.width,
            width: mq.size.width,
            height: mq.size.height,
            child: showLivenessCamera
                ? LivenessDetectionView(
                    onLivenessTestCompleted: onLivenessTestCompleted,
                    language: widget.language,
                    options: widget.livenessDetectionOptions,
                  )
                : Container(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
