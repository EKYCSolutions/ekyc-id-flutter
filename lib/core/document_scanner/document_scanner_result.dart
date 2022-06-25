import 'dart:typed_data';

import 'document_scanner_values.dart';

class DocumentScannerResult {
  late ObjectDetectionObjectType documentType;
  late ObjectDetectionObjectGroup documentGroup;
  late Uint8List fullImage;
  late Uint8List documentImage;
  late Uint8List? faceImage;

  DocumentScannerResult({
    required this.documentType,
    required this.documentGroup,
    required this.fullImage,
    required this.documentImage,
    this.faceImage,
  });

  DocumentScannerResult.fromMap(Map<String, dynamic> json) {
    ObjectDetectionObjectGroup documentGroup = ObjectDetectionObjectGroup.values
        .firstWhere((e) =>
            e.toString() ==
            "ObjectDetectionObjectGroup.${json['documentGroup']}");
    this.documentGroup = documentGroup;

    ObjectDetectionObjectType documentType = ObjectDetectionObjectType.values
        .firstWhere((e) =>
            e.toString() ==
            "ObjectDetectionObjectType.${json['documentType']}");
    this.documentType = documentType;

    this.fullImage = Uint8List.fromList(json["fullImage"]);
    this.documentImage = Uint8List.fromList(json["documentImage"]);

    if (json["faceImage"] != null) {
      this.faceImage = Uint8List.fromList(json["faceImage"]);
    }
  }
}
