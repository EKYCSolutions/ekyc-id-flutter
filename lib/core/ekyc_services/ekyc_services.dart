import 'package:dio/dio.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_values.dart';
import 'package:ekyc_id_flutter/core/ekyc_services/src/ekyc_services_option.dart';
import 'package:ekyc_id_flutter/core/ekyc_services/src/errors.dart';
import 'package:ekyc_id_flutter/core/ekyc_services/src/requests_builder.dart';
import 'package:ekyc_id_flutter/core/models/face_sequence.dart';
import 'package:ekyc_id_flutter/core/models/api_result.dart';

export 'package:dio/dio.dart' show BaseOptions;

/// Class for accessing EkycID apis.
class EkycIDServices {
  /// Configuration options for http client.
  /// Set timeout using [connectTimeout] and [recieveTimeout]
  BaseOptions? httpOptions;

  /// Interceptors to be added during init.
  /// For retry interceptor or logging
  List<Interceptor>? interceptors;

  final Dio _http = Dio();
  late EkycServicesOptions _options;

  EkycIDServices._internal();

  initialize({required EkycServicesOptions options}) {
    _options = options;
    _http.options = options.httpOptions;
    _http.interceptors.addAll(options.interceptors);
    _http.interceptors.add(EkycErrorInterceptors(_http));
  }

  static final EkycIDServices instance = EkycIDServices._internal();

  /// Calls face compare api to get comparison scores between [faceImage1] and [faceImage2]
  Future<ApiResult> faceCompare({
    required List<int> faceImage1,
    required List<int> faceImage2,
  }) async {
    Response response = await _http.post(
      "${this._options.serverUrl}/v0/face-compare",
      data: RequestsBuilder.buildFaceCompare(
        faceImage1: faceImage1,
        faceImage2: faceImage2,
      ),
    );

    Map<String, dynamic> json = Map<String, dynamic>.from(response.data);
    return ApiResult.fromJson(json);
  }

  /// Calls ocr api to perform ocr on [image] that has the type [objectType]
  Future<ApiResult> ocr({
    required List<int> image,
    required ObjectDetectionObjectType objectType,
  }) async {
    Response response = await _http.post("${this._options.serverUrl}/v0/ocr",
        data: RequestsBuilder.buildOCRForm(
          image: image,
          objectType: objectType,
        ));

    if (response.data == null) {
      throw "cannot extract information";
    }

    Map<String, dynamic> json = Map<String, dynamic>.from(response.data);

    return ApiResult.fromJson(json);
  }

  //
  Future<ApiResult> manualKyc({
    required ObjectDetectionObjectType objectType,
    required List<int> ocrImage,
    required List<int> faceImage,
    required List<int> faceLeftImage,
    required List<int> faceRightImage,
  }) async {
    Response response = await _http.post(
      "${this._options.serverUrl}/v0/manual-kyc",
      data: RequestsBuilder.buildManualKYC(
        objectType: objectType,
        ocrImage: ocrImage,
        faceImage: faceImage,
        faceLeftImage: faceLeftImage,
        faceRightImage: faceRightImage,
      ),
    );

    Map<String, dynamic> json = Map<String, dynamic>.from(response.data);
    return ApiResult.fromJson(json);
  }

  Future<ApiResult> expressKyc({
    required ObjectDetectionObjectType objectType,
    required List<int> ocrImage,
    required List<FaceSequence> sequences,
  }) async {
    Response response = await _http.post(
      "${this._options.serverUrl}/v0/express-kyc",
      data: await RequestsBuilder.buildExpressKYC(
        objectType: objectType,
        ocrImage: ocrImage,
        sequences: sequences,
      ),
    );

    Map<String, dynamic> json = Map<String, dynamic>.from(response.data);
    return ApiResult.fromJson(json);
  }
}
