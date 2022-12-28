import 'package:ekyc_id_flutter/core/models/language.dart';
import 'package:flutter/material.dart';

import 'package:ekyc_id_flutter/core/models/frame_status.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_values.dart';

import 'scanner_ring.dart';
import 'scanner_message.dart';
import 'doc_minimal_values.dart';
import 'document_side_indicator.dart';

class DocMinimalOverlay extends StatelessWidget {
  const DocMinimalOverlay({
    Key? key,
    required this.frameStatus,
    required this.currentSide,
    this.showFlippingAnimation = false,
    this.language = Language.EN,
  }) : super(key: key);

  final Language language;
  
  final FrameStatus frameStatus;
  final DocumentSide currentSide;
  final bool showFlippingAnimation;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Stack(
      children: [
        Center(
          child: showFlippingAnimation
              ? DocumentSideIndicator()
              : ScannerRing(frameStatus: frameStatus),
        ),
        Positioned(
          top: (mq.size.height / 2) + (SCANNER_RIGHT_SIZE / 2) + 10,
          left: 0,
          right: 0,
          child: Center(
            child: ScannerMessage(
              language: language,
              frameStatus: frameStatus,
              currentSide: currentSide,
            ),
          ),
        )
      ],
    );
  }
}
