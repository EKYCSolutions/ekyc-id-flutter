import 'dart:typed_data';

import 'package:ekyc_id_flutter/core/models/frame_status.dart';

import 'document_scanner_controller.dart';
import 'document_scanner_result.dart';

typedef void DocumentScannerCreatedCallback(
  DocumentScannerController controller,
);

typedef void DocumentScannerOnFrameCallback(FrameStatus frameStatus);

typedef void DocumentScannerOnDetectionCallback(DocumentScannerResult result);

typedef void DocumentScannerOnInitializedCallback();

typedef Future<void> OnDocumentScannedCallback({
  required DocumentScannerResult mainSide,
  DocumentScannerResult? secondarySide,
});

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

enum DocumentSide { MAIN, SECONDARY }

enum DocumentScannerDocType { NATIONAL_ID, DRIVER_LICENSE }

const DOC_TYPE_WHITE_LIST_MAPPING = {
  DocumentScannerDocType.NATIONAL_ID: {
    DocumentSide.MAIN: [
      ObjectDetectionObjectGroup.NATIONAL_ID,
    ],
    DocumentSide.SECONDARY: [
      ObjectDetectionObjectGroup.NATIONAL_ID_BACK,
    ],
  },
  DocumentScannerDocType.DRIVER_LICENSE: {
    DocumentSide.MAIN: [
      ObjectDetectionObjectGroup.DRIVER_LICENSE,
    ],
    DocumentSide.SECONDARY: [
      ObjectDetectionObjectGroup.DRIVER_LICENSE_BACK,
    ],
  },
};

const DOCUMENTS_WITH_SECONDARY_SIDE = [
  ObjectDetectionObjectType.COVID_19_VACCINATION_CARD_0,
  ObjectDetectionObjectType.COVID_19_VACCINATION_CARD_1,
  ObjectDetectionObjectType.DRIVER_LICENSE_0,
  ObjectDetectionObjectType.DRIVER_LICENSE_1,
  ObjectDetectionObjectType.NATIONAL_ID_0,
  ObjectDetectionObjectType.NATIONAL_ID_1,
  ObjectDetectionObjectType.NATIONAL_ID_2,
  ObjectDetectionObjectType.PASSPORT_0,
  ObjectDetectionObjectType.SUPERFIT_0,
  ObjectDetectionObjectType.VEHICLE_REGISTRATION_0,
  ObjectDetectionObjectType.VEHICLE_REGISTRATION_1,
  ObjectDetectionObjectType.VEHICLE_REGISTRATION_2,
];

extension ObjectDetectionObjectTypeToString on ObjectDetectionObjectType {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

extension ObjectDetectionObjectGroupToString on ObjectDetectionObjectGroup {
  String toShortString() {
    return this.toString().split('.').last;
  }
}
