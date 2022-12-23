// /// Class representing configurations of the [DocumentScanner].
// class DocumentScannerOptions {

//   /// The duration is seconds to wait before capturing the frame for process.
//   final int preparingDuration;

//   const DocumentScannerOptions({
//     this.preparingDuration = 2,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       "preparingDuration": preparingDuration,
//     };
//   }
// }

import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_values.dart';

/// Class representing configurations of the [DocumentScanner].
class DocumentScannerOptions {
  /// The duration is seconds to wait before capturing the frame for process.
  final List<ScannableDocument> scannableDocuments;

  ///
  final int preparingDuration;

  const DocumentScannerOptions({
    required this.scannableDocuments,
    this.preparingDuration = 5,
  });

  Map<String, dynamic> toMap() {
    return {
      "preparingDuration": preparingDuration,
      "scannableDocuments":
          scannableDocuments.map((document) => document.toMap()).toList()
    };
  }
}

class ScannableDocument {
  final ObjectDetectionObjectType mainSide;
  final ObjectDetectionObjectType? secondarySide;

  const ScannableDocument({
    required this.mainSide,
    this.secondarySide,
  });

  Map<String, dynamic> toMap() {
    return {
      "mainSide": mainSide.toShortString(),
      "secondarySide":
          secondarySide == null ? null : secondarySide!.toShortString(),
    };
  }
}
