import 'package:dio/dio.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_values.dart';
import 'package:ekyc_id_flutter/core/ekyc_services/src/errors.dart';
import 'package:ekyc_id_flutter/core/ekyc_services/src/requests_builder.dart';
import 'package:ekyc_id_flutter/core/models/face_sequence.dart';
import 'package:ekyc_id_flutter/core/models/api_result.dart';

class EkycServiceOptions extends BaseOptions {
  /// The request config extended from [BaseOptions] from Dio package.
  EkycServiceOptions({
    String? method,
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    ResponseType? responseType = ResponseType.json,
    String? contentType,
    ValidateStatus? validateStatus,
    bool? receiveDataWhenStatusError,
    bool? followRedirects,
    int? maxRedirects,
    RequestEncoder? requestEncoder,
    ResponseDecoder? responseDecoder,
    ListFormat? listFormat,
  }) : super(
          method: method,
          receiveTimeout: receiveTimeout,
          sendTimeout: sendTimeout,
          extra: extra,
          headers: headers,
          responseType: responseType,
          contentType: contentType,
          validateStatus: validateStatus,
          receiveDataWhenStatusError: receiveDataWhenStatusError,
          followRedirects: followRedirects,
          maxRedirects: maxRedirects,
          requestEncoder: requestEncoder,
          responseDecoder: responseDecoder,
          listFormat: listFormat,
        ) {
    this.queryParameters = queryParameters ?? {};
    this.baseUrl = baseUrl;
    this.connectTimeout = connectTimeout ?? 0;
  }
}

/// Class for accessing EkycID apis.
class EkycIDServices {
  late String _url;

  /// Configuration options for http client.
  /// Set timeout using [connectTimeout] and [recieveTimeout]
  EkycServiceOptions? httpOptions;

  /// Interceptors to be added during init.
  /// For retry interceptor or logging
  List<Interceptor>? interceptors;

  final Dio _http = Dio();

  EkycIDServices._internal();

  EkycIDServices() {
    _configOptions();
    _configInterceptors();
  }

  void _configOptions() {
    if (httpOptions != null) {
      _http.options = httpOptions!;
    } else {
      _http.options = BaseOptions(
        connectTimeout: 60 * 1000,
        receiveTimeout: 60 * 1000,
        extra: {"withCredentials": false},
      );
    }
  }

  void _configInterceptors() {
    if (interceptors != null && interceptors!.isNotEmpty) {
      _http.interceptors.add(EkycErrorInterceptors(_http));
      _http.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
            return handler.next(options);
          },
          onError: (DioError dioError, ErrorInterceptorHandler handler) {
            return handler.next(dioError);
          },
        ),
      );
      _http.interceptors.addAll(interceptors!);
    }
  }

  static final EkycIDServices instance = EkycIDServices._internal();

  /// set the base url for server
  void setURL(String url) {
    this._url = url;
  }

  /// Calls face compare api to get comparison scores between [faceImage1] and [faceImage2]
  Future<ApiResult> faceCompare({
    required List<int> faceImage1,
    required List<int> faceImage2,
  }) async {
    Response response = await _http.post(
      "${this._url}/v0/face-compare",
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
    Response response = await _http.post("${this._url}/v0/ocr",
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
      "${this._url}/v0/manual-kyc",
      data: RequestsBuilder.buildManualKYC(
          objectType: objectType,
          ocrImage: ocrImage,
          faceImage: faceImage,
          faceLeftImage: faceLeftImage,
          faceRightImage: faceRightImage),
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
      "${this._url}/v0/express",
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
