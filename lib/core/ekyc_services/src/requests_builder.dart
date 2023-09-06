import 'package:dio/dio.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_values.dart';
import 'package:ekyc_id_flutter/core/models/face_sequence.dart';
import 'package:http_parser/http_parser.dart';

class RequestsBuilder {
  static FormData buildFaceCompare({
    required List<int> faceImage1,
    required List<int> faceImage2,
  }) {
    FormData formData = FormData();

    formData.files.addAll([
      MapEntry(
          "faceImage0",
          MultipartFile.fromBytes(
            faceImage1,
            contentType: MediaType("image", "jpg"),
            filename: "faceImage0.jpg",
          )),
      MapEntry(
          "faceImage1",
          MultipartFile.fromBytes(
            faceImage2,
            contentType: MediaType("image", "jpg"),
            filename: "faceImage1.jpg",
          )),
    ]);

    return formData;
  }

  static FormData buildOCRForm({
    required List<int> image,
    required ObjectDetectionObjectType objectType,
  }) {
    MultipartFile file = MultipartFile.fromBytes(
      image,
      contentType: MediaType("image", "jpg"),
      filename: "card.jpg",
    );
    final form = FormData.fromMap({
      "objectType": objectType.toShortString(),
    });
    form.files.add(MapEntry("image", file));

    return form;
  }

  static FormData buildManualKYC({
    required ObjectDetectionObjectType objectType,
    required List<int> ocrImage,
    required List<int> faceImage,
    required List<int> faceLeftImage,
    required List<int> faceRightImage,
  }) {
    final form = FormData.fromMap({
      "objectType": objectType.toShortString(),
    });
    form.files.addAll([
      MapEntry("ocrImage", MultipartFile.fromBytes(ocrImage)),
      MapEntry("faceImage", MultipartFile.fromBytes(faceImage)),
      MapEntry("faceLeftImage", MultipartFile.fromBytes(faceLeftImage)),
      MapEntry("faceRightImage", MultipartFile.fromBytes(faceRightImage)),
    ]);

    return form;
  }

  static Future<FormData> buildExpressKYC({
    required ObjectDetectionObjectType objectType,
    required List<int> ocrImage,
    required List<FaceSequence> sequences,
  }) async {
    final form = FormData.fromMap({
      "objectType": objectType.toShortString(),
    });

    form.files.addAll([
      MapEntry("ocrImage", MultipartFile.fromBytes(ocrImage)),
    ]);
    sequences.forEach((prompt) async {
      form.fields.add(MapEntry("checks", prompt.check));
      form.files.add(
          MapEntry("videos", await MultipartFile.fromFile(prompt.videoPath)));
    });

    return form;
  }
}
