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

extension ObjectDetectionObjectTypeToString on ObjectDetectionObjectType {
  String toShortString() {
    return this.toString().split('.').last;
  }
}
