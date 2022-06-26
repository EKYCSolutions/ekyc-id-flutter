import 'package:dio/dio.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_values.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ekyc_id_flutter/core/models/api_result.dart';

class EkycIDServices {
  late String _url;

  EkycIDServices._internal();

  static final EkycIDServices instance = EkycIDServices._internal();

  void setURL(String url) {
    this._url = url;
  }

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

      Dio dio = Dio();
      MultipartFile file1 = MultipartFile.fromBytes(
        faceImage1,
        contentType: MediaType("image", "jpg"),
        filename: "image1.jpg",
      );
      MultipartFile file2 = MultipartFile.fromBytes(
        faceImage2,
        contentType: MediaType("image", "jpg"),
        filename: "image2.jpg",
      );
      FormData formData = FormData();
      MapEntry<String, MultipartFile> img1 = MapEntry("image1", file1);
      MapEntry<String, MultipartFile> img2 = MapEntry("image2", file2);
      formData.files.add(img1);
      formData.files.add(img2);

      Response response = await dio.post(
        "${this._url}/v0/face-compare",
        data: formData,
      );

      Map<String, dynamic> json = Map<String, dynamic>.from(response.data);
      return ApiResult.fromJson(json);
    } on DioError catch (e) {
      throw e.toString();
    }
  }

  Future<ApiResult> ocr({
    required List<int> image,
    required ObjectDetectionObjectType objectType,
  }) async {
    try {
      Dio dio = Dio();
      MultipartFile file = MultipartFile.fromBytes(
        image,
        contentType: MediaType("image", "jpg"),
        filename: "card.jpg",
      );
      FormData formData = FormData.fromMap({
        "object_type": objectType.toShortString(),
        "is_raw": true,
      });

      MapEntry<String, MultipartFile> imageField = MapEntry("card_image", file);

      formData.files.add(imageField);

      Response response = await dio.post(
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
}
