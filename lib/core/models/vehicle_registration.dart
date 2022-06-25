class VehicleRegistration {
  String? ADDRESS;
  String? BRAND;
  String? COLOR;
  String? ISSUE_DATE;
  String? NAME_ENG;
  String? NAME_KHM;
  String? PLATE_NUMBER;
  String? TYPE;
  String? VEHICLE_TYPE;

  VehicleRegistration({
    this.ADDRESS,
    this.BRAND,
    this.COLOR,
    this.ISSUE_DATE,
    this.NAME_ENG,
    this.NAME_KHM,
    this.PLATE_NUMBER,
    this.TYPE,
    this.VEHICLE_TYPE,
  });

  VehicleRegistration.fromJson(Map<String, dynamic> json) {
    print(json);
    this.ADDRESS = json["ADDRESS"];
    this.BRAND = json["BRAND"];
    this.COLOR = json["COLOR"];
    this.ISSUE_DATE = json["ISSUE_DATE"];
    this.NAME_ENG = json["NAME_ENG"];
    this.NAME_KHM = json["NAME_KHM"];
    this.PLATE_NUMBER = json["PLATE_NUMBER"];
    this.TYPE = json["TYPE"];
    this.VEHICLE_TYPE = json["VEHICLE_TYPE"];
  }
}
