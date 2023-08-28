import 'package:dio/dio.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_values.dart';
import 'package:ekyc_id_flutter/core/models/sequence.dart';
import 'package:http_parser/http_parser.dart';
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
    required List<int>? faceImage1,
    required List<int>? faceImage2,
  }) async {
    try {
      if (faceImage1 == null) {
        throw "faceImage1 not found";
      }

      if (faceImage2 == null) {
        throw "faceImage2 not found";
      }

      MultipartFile file1 = MultipartFile.fromBytes(
        faceImage1,
        contentType: MediaType("image", "jpg"),
        filename: "faceImage0.jpg",
      );
      MultipartFile file2 = MultipartFile.fromBytes(
        faceImage2,
        contentType: MediaType("image", "jpg"),
        filename: "faceImage1.jpg",
      );
      FormData formData = FormData();
      MapEntry<String, MultipartFile> img1 = MapEntry("faceImage0", file1);
      MapEntry<String, MultipartFile> img2 = MapEntry("faceImage1", file2);
      formData.files.add(img1);
      formData.files.add(img2);

      Response response = await _http.post(
        "${this._url}/v0/face-compare",
        data: formData,
      );

      Map<String, dynamic> json = Map<String, dynamic>.from(response.data);
      return ApiResult.fromJson(json);
    } on DioError catch (e) {
      throw e.toString();
    }
  }

  /// Calls ocr api to perform ocr on [image] that has the type [objectType]
  Future<ApiResult> ocr({
    required List<int> image,
    required ObjectDetectionObjectType objectType,
  }) async {
    try {
      MultipartFile file = MultipartFile.fromBytes(
        image,
        contentType: MediaType("image", "jpg"),
        filename: "card.jpg",
      );
      FormData formData = FormData.fromMap({
        "objectType": objectType.toShortString(),
        "isRaw": "yes",
      });

      MapEntry<String, MultipartFile> imageField = MapEntry("image", file);

      formData.files.add(imageField);

      Response response = await _http.post(
        "${this._url}/v0/ocr",
        data: formData,
      );

      if (response.data == null) {
        throw "cannot extract information";
      }

      Map<String, dynamic> json = Map<String, dynamic>.from(response.data);

      return ApiResult.fromJson(json);
    } on DioError catch (e) {
      throw e.toString();
    }
  }

  //
  Future<ApiResult> manualKyc({
    required ObjectDetectionObjectType objectType,
    required List<int> ocrImage,
    List<int>? faceImage,
    List<int>? faceLeftImage,
    List<int>? faceRightImage,
    List<Sequence> sequences = const [],
  }) async {
    assert((faceImage != null &&
            faceLeftImage != null &&
            faceRightImage != null) ||
        sequences.isNotEmpty);
    try {
      FormData formData = FormData();

      formData.files.add(
        MapEntry(
          "ocr_image",
          MultipartFile.fromBytes(ocrImage),
        ),
      );

      if (faceImage != null &&
          faceLeftImage != null &&
          faceRightImage != null) {
        formData.files.addAll([
          MapEntry(
            "faceFrontSideImage",
            MultipartFile.fromBytes(
              faceImage,
              contentType: MediaType("image", "jpg"),
              filename: "faceFrontSideImage.jpg",
            ),
          ),
          MapEntry(
            "faceLeftSideImage",
            MultipartFile.fromBytes(
              faceLeftImage,
              contentType: MediaType("image", "jpg"),
              filename: "faceLeftSideImage.jpg",
            ),
          ),
          MapEntry(
            "faceRightSideImage",
            MultipartFile.fromBytes(
              faceRightImage,
              contentType: MediaType("image", "jpg"),
              filename: "faceRightSideImage.jpg",
            ),
          ),
        ]);
      } else if (sequences.isNotEmpty) {
        for (var i = 0; i < sequences.length; i++) {
          // formData.fields.add( MapEntry("sequences[$i]", MapEntry("checks", sequences[i].checks),))
          formData.fields.add(MapEntry(
            "sequence[$i]",
            sequences[i].check,
          ));

          formData.files.add(
            MapEntry(
              "sequence[$i]",
              await MultipartFile.fromFile(
                sequences[i].videoPath,
                filename: "${sequences[i].check}_video",
                contentType: MediaType("video", "avi"),
              ),
            ),
          );
        }
      } else {
        throw "Invalid request";
      }

      Response response = await _http.post(
        "${this._url}/v0/manual-kyc",
        data: formData,
      );

      Map<String, dynamic> json = Map<String, dynamic>.from(response.data);
      return ApiResult.fromJson(json);
    } on DioError catch (e) {
      throw e.toString();
    }
  }

  Future<ApiResult> expressKyc({
    required List<int>? faceImage,
    required List<int>? documentImage,
  }) async {
    try {
      if (faceImage == null) {
        throw "faceImage not found";
      }
      if (documentImage == null) {
        throw "faceImage not found";
      }

      MultipartFile file1 = MultipartFile.fromBytes(
        faceImage,
        contentType: MediaType("image", "jpg"),
        filename: "faceImage0.jpg",
      );
      MultipartFile file2 = MultipartFile.fromBytes(
        documentImage,
        contentType: MediaType("image", "jpg"),
        filename: "documentImage0.jpg",
      );

      FormData formData = FormData();
      MapEntry<String, MultipartFile> img1 = MapEntry("faceImage0", file1);

      formData.files.add(img1);

      Response response = await _http.post(
        "${this._url}/v0/express",
        data: formData,
      );

      Map<String, dynamic> json = Map<String, dynamic>.from(response.data);
      return ApiResult.fromJson(json);
    } on DioError catch (e) {
      throw e.toString();
    }
  }
}
