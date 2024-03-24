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

extension ObjectDetectionObjectGroupToString on ObjectDetectionObjectGroup {
  String toShortString() {
    return this.toString().split('.').last;
  }
}
