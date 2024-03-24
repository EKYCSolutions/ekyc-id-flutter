/// Class representing the response from EkyID services. (e.g face-compare, ocr)
class ApiResult {

  /// The response from EkycID service. Depending on API, the response can be face-compare score or document ocr response.
  Map<String, dynamic>? data;

  /// The error message from the api call.
  String? message;

  /// The errorCode returned from the server.
  String? errorCode;

  /// Boolean indicating if the api call was a success.
  bool? isSuccess;

  /// The end time of the api call.
  String? endTime;

  /// The start time of the api call.
  String? startTime;

  /// The duration of the api call.
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

  /// Creates an instance of ApiResult from a [json] response.
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
