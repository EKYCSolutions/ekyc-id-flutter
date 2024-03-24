class DriverLicense {
  String? ADDRESS;
  String? ADDRESS_ENG;
  String? CARD_NUMBER;
  String? CATEGORIES;
  String? DATE_OF_BIRTH;
  String? ENGLISH_NAME;
  String? EXPIRY_DATE;
  String? ID_NUMBER;
  String? ISSUE_DATE;
  String? KHMER_NAME;
  String? NATIONALITY_ENG;
  String? NATIONALITY_KHM;
  String? PLACE_OF_BIRTH;
  String? PLACE_OF_BIRTH_KHM;
  String? SEX;
  String? SPECIAL_CONDITION_ENG;
  String? SPECIAL_CONDITION_KHM;

  DriverLicense({
    this.ADDRESS,
    this.ADDRESS_ENG,
    this.CARD_NUMBER,
    this.CATEGORIES,
    this.DATE_OF_BIRTH,
    this.ENGLISH_NAME,
    this.EXPIRY_DATE,
    this.ID_NUMBER,
    this.ISSUE_DATE,
    this.KHMER_NAME,
    this.NATIONALITY_ENG,
    this.NATIONALITY_KHM,
    this.PLACE_OF_BIRTH,
    this.PLACE_OF_BIRTH_KHM,
    this.SEX,
    this.SPECIAL_CONDITION_ENG,
    this.SPECIAL_CONDITION_KHM,
  });

  DriverLicense.fromJson(Map<String, dynamic> json) {
    this.ADDRESS = json["ADDRESS"];
    this.ADDRESS_ENG = json["ADDRESS_ENG"];
    this.CARD_NUMBER = json["CARD_NUMBER"];
    this.CATEGORIES = json["CATEGORIES"];
    this.DATE_OF_BIRTH = json["DATE_OF_BIRTH"];
    this.ENGLISH_NAME = json["ENGLISH_NAME"];
    this.EXPIRY_DATE = json["EXPIRY_DATE"];
    this.ID_NUMBER = json["ID_NUMBER"];
    this.ISSUE_DATE = json["ISSUE_DATE"];
    this.KHMER_NAME = json["KHMER_NAME"];
    this.NATIONALITY_ENG = json["NATIONALITY_ENG"];
    this.NATIONALITY_KHM = json["NATIONALITY_KHM"];
    this.PLACE_OF_BIRTH = json["PLACE_OF_BIRTH"];
    this.PLACE_OF_BIRTH_KHM = json["PLACE_OF_BIRTH_KHM"];
    this.SEX = json["SEX"];
    this.SPECIAL_CONDITION_ENG = json["SPECIAL_CONDITION_ENG"];
    this.SPECIAL_CONDITION_KHM = json["SPECIAL_CONDITION_KHM"];
  }
}
