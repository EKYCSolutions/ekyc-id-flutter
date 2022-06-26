import 'package:flutter/material.dart';

import 'package:ekyc_id_flutter/core/language.dart';
import 'package:ekyc_id_flutter/core/models/language.dart';
import 'package:ekyc_id_flutter/core/models/frame_status.dart';

class ScannerMessage extends StatelessWidget {
  const ScannerMessage({
    Key? key,
    this.language = Language.EN,
    this.frameStatus = FrameStatus.INITIALIZING,
  }) : super(key: key);

  final Language language;
  final FrameStatus? frameStatus;

  @override
  Widget build(BuildContext context) {
    const Map<FrameStatus, String?> STATUS_MAPPING = {
      FrameStatus.INITIALIZING: "initializing",
      FrameStatus.FACE_FOUND: "processing",
      FrameStatus.PREPARING: "preparing",
      FrameStatus.PROCESSING: "processing",
      FrameStatus.FACE_TOO_BIG: "move_back",
      FrameStatus.FACE_TOO_SMALL: "move_closer",
      FrameStatus.NO_FACE_FOUND: "place_face_at_the_center",
      FrameStatus.MULTIPLE_FACES_FOUND: "multiple_faces_found",
      FrameStatus.FACE_NOT_IN_CENTER: "place_face_at_the_center",
    };

    if (STATUS_MAPPING[frameStatus] == null) {
      return Material();
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        LANGUAGE[STATUS_MAPPING[frameStatus]!]![language]!,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
