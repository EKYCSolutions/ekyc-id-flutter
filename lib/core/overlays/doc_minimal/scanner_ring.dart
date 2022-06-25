import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:ekyc_id_flutter/core/models/frame_status.dart';

import 'dual_ring.dart';
import 'dual_ring_fast.dart';
import 'doc_minimal_values.dart';

class ScannerRing extends StatefulWidget {
  const ScannerRing({
    Key? key,
    this.frameStatus = FrameStatus.INITIALIZING,
  }) : super(key: key);

  final FrameStatus frameStatus;

  @override
  _ScannerRingState createState() => _ScannerRingState();
}

class _ScannerRingState extends State<ScannerRing> {
  Widget _buildInnerRing(Color c) {
    if (const [
      FrameStatus.DOCUMENT_NOT_FOUND,
      FrameStatus.DOCUMENT_NOT_IN_CENTER,
      FrameStatus.DOCUMENT_TOO_BIG,
      FrameStatus.DOCUMENT_TOO_SMALL,
    ].contains(widget.frameStatus)) {
      return DualRing(
        color: c,
        lineWidth: 3,
      );
    }

    if (const [FrameStatus.PREPARING, FrameStatus.PROCESSING]
        .contains(widget.frameStatus)) {
      return SpinKitPulse(color: c);
    }

    return DualRingFast(
      color: c,
      lineWidth: 3,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SCANNER_RIGHT_SIZE,
      width: SCANNER_RIGHT_SIZE,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(SCANNER_RIGHT_SIZE / 2),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: DOT_WIDTH,
              height: DOT_WIDTH,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DOT_WIDTH / 2),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                width: INNER_RIGHT_SIZE,
                height: INNER_RIGHT_SIZE,
                child: _buildInnerRing(Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
