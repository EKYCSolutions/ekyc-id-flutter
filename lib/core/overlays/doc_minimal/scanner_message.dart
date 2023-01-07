import 'package:ekyc_id_flutter/core/models/language.dart';
import 'package:flutter/material.dart';
import 'package:ekyc_id_flutter/core/language.dart';
import 'package:ekyc_id_flutter/core/models/frame_status.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_values.dart';

class ScannerMessage extends StatelessWidget {
  const ScannerMessage({
    Key? key,
    this.language = Language.EN,
    this.currentSide = DocumentSide.MAIN,
    this.frameStatus = FrameStatus.INITIALIZING,
  }) : super(key: key);

  final Language language;
  final FrameStatus frameStatus;
  final DocumentSide currentSide;

  @override
  Widget build(BuildContext context) {
    Map<FrameStatus, String?> message = {
      FrameStatus.DOCUMENT_FOUND: null,
      FrameStatus.INITIALIZING: "initializing",
      FrameStatus.PREPARING: "preparing",
      FrameStatus.PROCESSING: "processing",
      FrameStatus.DOCUMENT_TOO_BIG: "move_back",
      FrameStatus.DOCUMENT_TOO_SMALL: "move_closer",
      FrameStatus.DOCUMENT_NOT_FOUND:
          "scan_the_${currentSide == DocumentSide.MAIN ? 'front' : 'back'}_of_the_document",
      FrameStatus.DOCUMENT_NOT_IN_CENTER: "place_document_at_the_center",
      FrameStatus.CANNOT_GRAB_FACE: "face_not_found",
      FrameStatus.DOCUMENT_BLUR: "document_blur",
      FrameStatus.CANNOT_GRAB_DOCUMENT: "document_not_found",
    };

    if (message[frameStatus] == null) {
      return Material();
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        LANGUAGE[message[frameStatus]!]![language]!,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}
