import 'package:ekyc_id_flutter/core/models/frame_status.dart';

import 'document_scanner_result.dart';
import 'document_scanner_controller.dart';

/// Callback for when the native view of the Document Scanner is created.
typedef void DocumentScannerCreatedCallback(
  DocumentScannerController controller,
);

/// Callback on every frame during the document scanning process.
typedef void DocumentScannerOnFrameCallback(FrameStatus frameStatus);

/// Callback for when the document scanner detects a presence of a document.
typedef void DocumentScannerOnDetectionCallback(DocumentScannerResult result);

/// Callback for when the document scanner is initialized.
typedef void DocumentScannerOnInitializedCallback();

/// Callback for when the document scanning process is completed.
typedef Future<void> OnDocumentScannedCallback({
  required DocumentScannerResult mainSide,
  DocumentScannerResult? secondarySide,
});

/// Enum indicating the object type of the document
///
/// Refers to this [page](https://www.ekycsolutions.com) for images of each document type.
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

/// Enum indicating the group the document belongs to.
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

/// Enum indicating the side of the document.
enum DocumentSide { MAIN, SECONDARY }

/// Enum indicating the supported document type of of the document.
enum DocumentScannerDocType { NATIONAL_ID, DRIVER_LICENSE }

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
