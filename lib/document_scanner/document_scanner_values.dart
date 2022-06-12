import 'dart:typed_data';

import 'package:ekyc_id_flutter/models/frame_status.dart';

import 'document_scanner_controller.dart';

typedef void DocumentScannerCreatedCallback(
  DocumentScannerController controller,
);

typedef void DocumentScannerOnFrameCallback(FrameStatus frameStatus);

typedef void DocumentScannerOnDetectionCallback(DocumentScannerResult result);

typedef void DocumentScannerOnInitializedCallback();

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

enum ObjectDetectionObjectType {
  COVID_19_VACCINATION_CARD_0,
  COVID_19_VACCINATION_CARD_0_BACK,
  COVID_19_VACCINATION_CARD_1,
  COVID_19_VACCINATION_CARD_1_BACK,
  DRIVER_LICENSE_0,
  DRIVER_LICENSE_0_BACK,
  DRIVER_LICENSE_1,
  DRIVER_LICENSE_1_BACK,
  LICENSE_PLATE_0_0,
  LICENSE_PLATE_0_1,
  LICENSE_PLATE_1_0,
  LICENSE_PLATE_2_0,
  LICENSE_PLATE_3_0,
  LICENSE_PLATE_3_1,
  NATIONAL_ID_0,
  NATIONAL_ID_0_BACK,
  NATIONAL_ID_1,
  NATIONAL_ID_1_BACK,
  NATIONAL_ID_2,
  NATIONAL_ID_2_BACK,
  PASSPORT_0,
  PASSPORT_0_TOP,
  SUPERFIT_0,
  SUPERFIT_0_BACK,
  VEHICLE_REGISTRATION_0,
  VEHICLE_REGISTRATION_0_BACK,
  VEHICLE_REGISTRATION_1,
  VEHICLE_REGISTRATION_1_BACK,
  VEHICLE_REGISTRATION_2,
}

enum ObjectDetectionObjectGroup {
  COVID_19_VACCINATION_CARD,
  DRIVER_LICENSE,
  DRIVER_LICENSE_FRONT,
  DRIVER_LICENSE_BACK,
  LICENSE_PLATE,
  NATIONAL_ID,
  NATIONAL_ID_FRONT,
  NATIONAL_ID_BACK,
  VEHICLE_REGISTRATION,
  VEHICLE_REGISTRATION_FRONT,
  VEHICLE_REGISTRATION_BACK,
  PASSPORT,
  PASSPORT_TOP,
  PASSPORT_BOTTOM,
  OTHERS,
}
