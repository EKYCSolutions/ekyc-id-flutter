import 'dart:typed_data';

import '../core/models/object_detection_object_group.dart';
import '../core/models/object_detection_object_type.dart';

/// Enum indicating the side of the document.
enum DocumentSide { MAIN, SECONDARY }

/// Enum indicating the supported document type of of the document.
enum DocumentScannerDocType { NATIONAL_ID, DRIVER_LICENSE }

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

class DocumentScannerCameraOptions {
  final double roiSize;
  final double faceCropScale;
  final int captureDurationCountDown;
  final double minDocWidthPercentage;
  final double maxDocWidthPercentage;

  const DocumentScannerCameraOptions({
    this.roiSize = 100,
    this.faceCropScale = 1.4,
    this.maxDocWidthPercentage = 1,
    this.minDocWidthPercentage = 0.7,
    this.captureDurationCountDown = 3,
  });

  Map<String, dynamic> toMap() {
    return {
      "roiSize": roiSize,
      "faceCropScale": faceCropScale,
      "maxDocWidthPercentage": maxDocWidthPercentage,
      "minDocWidthPercentage": minDocWidthPercentage,
      "captureDurationCountDown": captureDurationCountDown,
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
      "mainSide": this.mainSide.toShortString(),
      "secondarySide": this.secondarySide?.toShortString(),
    };
  }
}

/// Class representing configurations of the [DocumentScanner].
class DocumentScannerOptions {
  final DocumentScannerCameraOptions cameraOptions;
  final List<ScannableDocument> scannableDocuments;

  const DocumentScannerOptions({
    this.cameraOptions = const DocumentScannerCameraOptions(),
    this.scannableDocuments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      "cameraOptions": cameraOptions.toMap(),
      "scannableDocuments": scannableDocuments.map((e) => e.toMap()).toList(),
    };
  }
}
