import 'dart:developer';
import 'dart:typed_data';
import 'document_scanner_values.dart';

/// Class representing the result of the document scanning process.
class DocumentScannerResult {
  /// The type of document detected.
  late ObjectDetectionObjectType documentType;

  /// The group that the document belongs to.
  late ObjectDetectionObjectGroup documentGroup;

  /// The image of the frame when the document is detected.
  late Uint8List fullImage;

  /// The warped image of the detected document.
  late Uint8List documentImage;

  /// The face image existing in the document (If document has a face).
  late Uint8List? faceImage;

  DocumentScannerResult({
    required this.documentType,
    required this.documentGroup,
    required this.fullImage,
    required this.documentImage,
    this.faceImage,
  });

  /// Creates an instance of DocumentScannerResult from a [json] response.
  DocumentScannerResult.fromMap(Map<String, dynamic> json) {
    print('response in json $json');
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
