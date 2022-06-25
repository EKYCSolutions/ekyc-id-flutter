class NationalID {
  NationalIDEng? ENG;
  NationalIDKhm? KHM;

  NationalID({
    this.ENG,
    this.KHM,
  });

  NationalID.fromJson(Map<String, dynamic> json) {
    this.ENG = NationalIDEng.fromJson(json["ENG"]);
    this.KHM = NationalIDKhm.fromJson(json["KHM"]);
  }

  static String parsedDate(String? date) {
    if (date == null) {
      return "--";
    }

    String day = date.substring(date.length - 2);
    String month = date.substring(date.length - 4, date.length - 2);
    String year = date.substring(0, date.length - 4);

    return "$day/$month/$year";
  }
}

class NationalIDEng {
  String? FH;
  String? H1;
  String? H2;
  String? H3;
  String? doc;
  String? sex;
  String? country;
  String? fullName;
  String? lastName;
  String? birthDate;
  String? firstName;
  String? middleName;
  String? expiryDate;
  String? nationality;
  String? optionalData1;
  String? optionalData2;
  String? documentNumber;

  NationalIDEng.fromJson(Map<String, dynamic> json) {
    this.FH = json["FH"];
    this.H1 = json["H1"];
    this.H2 = json["H2"];
    this.H3 = json["H3"];
    this.sex = json["sex"];
    this.doc = json["doc"];
    this.country = json["country"];
    this.fullName = json["full_name"];
    this.lastName = json["last_name"];
    this.birthDate = json["birth_date"];
    this.firstName = json["first_name"];
    this.expiryDate = json["expiry_date"];
    this.middleName = json["middle_name"];
    this.nationality = json["nationality"];
    this.optionalData1 = json["optional_data_1"];
    this.optionalData2 = json["optional_data_2"];
    this.documentNumber = json["document_number"];
  }
}

class NationalIDKhm {
  String? MRZ_ENG;
  String? NAME_KH;
  String? HEIGHT_KH;
  String? ADDRESS_KH;
  String? IDENTIFY_KH;
  String? ADDRESS_1_KH;
  String? ADDRESS_2_KH;
  String? VALIDITY_END_KH;
  String? VALIDITY_START_KH;

  NationalIDKhm.fromJson(Map<String, dynamic> json) {
    this.ADDRESS_1_KH = json["ADDRESS_1_KH"];
    this.ADDRESS_2_KH = json["ADDRESS_2_KH"];
    this.MRZ_ENG = json["MRZ_ENG"];
    this.NAME_KH = json["NAME_KH"];
    this.HEIGHT_KH = json["HEIGHT_KH"];
    this.ADDRESS_KH = json["ADDRESS_KH"];
    this.IDENTIFY_KH = json["IDENTIFY_KH"];
    this.VALIDITY_END_KH = json["VALIDITY_END_KH"];
    this.VALIDITY_START_KH = json["VALIDITY_START_KH"];
  }
}
