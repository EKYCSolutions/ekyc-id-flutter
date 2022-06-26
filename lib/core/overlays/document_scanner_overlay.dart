import 'package:ekyc_id_flutter/core/models/language.dart';
import 'package:flutter/material.dart';

import 'package:ekyc_id_flutter/core/models/frame_status.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_values.dart';

import 'doc_minimal/doc_overlay_minimal.dart';

class DocumentScannerOverlay extends StatelessWidget {
  const DocumentScannerOverlay({
    Key? key,
    required this.frameStatus,
    required this.currentSide,
    this.language = Language.EN,
    this.showFlippingAnimation = false,
  }) : super(key: key);

  final Language language;
  final FrameStatus frameStatus;
  final DocumentSide currentSide;
  final bool showFlippingAnimation;

  @override
  Widget build(BuildContext context) {
    return DocMinimalOverlay(
      language: language,
      frameStatus: frameStatus,
      currentSide: currentSide,
      showFlippingAnimation: showFlippingAnimation,
    );
  }
}
