import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import 'models/driver_license.dart';
import 'models/national_id.dart';
import 'models/vehicle_registration.dart';

class EkycIDServices {
  static Future<double> faceCompare({
    required List<int>? image1,
    required List<int>? image2,
    required String url,
  }) async {
    try {
      if (image1 == null) {
        throw "image1 not found";
      }

      if (image2 == null) {
        throw "image2 not found";
      }

      Dio dio = Dio();
      MultipartFile file1 = MultipartFile.fromBytes(
        image1,
        contentType: MediaType("image", "jpg"),
        filename: "image1.jpg",
      );
      MultipartFile file2 = MultipartFile.fromBytes(
        image2,
        contentType: MediaType("image", "jpg"),
        filename: "image2.jpg",
      );
      FormData formData = FormData();
      MapEntry<String, MultipartFile> img1 = MapEntry("image1", file1);
      MapEntry<String, MultipartFile> img2 = MapEntry("image2", file2);
      formData.files.add(img1);
      formData.files.add(img2);

      Response response = await dio.post(
        url,
        data: formData,
      );

      Map<String, dynamic> json = Map<String, dynamic>.from(response.data);

      return (1 - json["distance"]).toDouble();
    } on DioError catch (e) {
      throw e.toString();
    }
  }

  static Future<dynamic> ocr<T>({
    required List<int> image,
    required String objectType,
  }) async {
    try {
      Dio dio = Dio();
      MultipartFile file = MultipartFile.fromBytes(
        image,
        contentType: MediaType("image", "jpg"),
        filename: "card.jpg",
      );
      FormData formData = FormData.fromMap({
        "object_type": objectType,
        "is_raw": true,
      });

      MapEntry<String, MultipartFile> imageField = MapEntry("card_image", file);

      formData.files.add(imageField);

      Response response = await dio.post(
        "",
        data: formData,
      );

      if (response.data == null) {
        return null;
      }

      Map<String, dynamic> json = Map<String, dynamic>.from(response.data);

      if (T == NationalID) {
        return NationalID.fromJson(json);
      }

      if (T == VehicleRegistration) {
        return VehicleRegistration.fromJson(json);
      }

      if (T == DriverLicense) {
        return DriverLicense.fromJson(json);
      }

      return json;
    } on DioError catch (e) {
      throw e.toString();
    }
  }
}
