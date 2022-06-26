class ApiResult {
  Map<String, dynamic>? data;
  String? message;
  String? errorCode;
  bool? isSuccess;
  String? endTime;
  String? startTime;
  int? timeElapsedAsSec;

  ApiResult({
    this.data,
    this.endTime,
    this.message,
    this.startTime,
    this.isSuccess,
    this.errorCode,
    this.timeElapsedAsSec,
  });

  ApiResult.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      this.data =
          json["data"] != null ? Map<String, dynamic>.from(json["data"]) : null;
      this.message = null;
      this.errorCode = json["errorCode"] ?? null;
      this.isSuccess = json["isSuccess"] ?? null;
      this.endTime = json["endTime"] ?? null;
      this.startTime = json["startTime"] ?? null;
      this.timeElapsedAsSec = json["timeElapsedAsSec"] ?? null;
    } else {
      this.data = null;
      this.message = null;
      this.errorCode = null;
      this.isSuccess = null;
      this.endTime = null;
      this.startTime = null;
      this.timeElapsedAsSec = null;
    }
  }
}
