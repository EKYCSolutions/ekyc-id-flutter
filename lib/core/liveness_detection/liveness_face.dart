import 'dart:typed_data';

import 'liveness_detection_values.dart';

class LivenessFace {
  late Uint8List image;
  late double? leftEyeOpenProbability;
  late double? rightEyeOpenProbability;
  late double? headEulerAngleX;
  late double? headEulerAngleY;
  late double? headEulerAngleZ;
  late FaceDetectionHeadDirection? headDirection;
  late FaceDetectionEyesStatus? eyesStatus;

  LivenessFace.fromMap(Map<String, dynamic> json) {
    this.image = Uint8List.fromList(json["image"]);
    this.leftEyeOpenProbability = json["leftEyeOpenProbability"];
    this.rightEyeOpenProbability = json["rightEyeOpenProbability"];
    this.headEulerAngleX = json["headEulerAngleX"];
    this.headEulerAngleY = json["headEulerAngleY"];
    this.headEulerAngleZ = json["headEulerAngleZ"];

    if (json["headDirection"] != null) {
      FaceDetectionHeadDirection d = FaceDetectionHeadDirection.values
          .firstWhere((e) =>
              e.toString() ==
              "FaceDetectionHeadDirection.${json['headDirection']}");
      this.headDirection = d;
    } else {
      this.headDirection = null;
    }

    if (json["eyesStatus"] != null) {
      FaceDetectionEyesStatus d = FaceDetectionEyesStatus.values.firstWhere(
          (e) =>
              e.toString() == "FaceDetectionEyesStatus.${json['eyesStatus']}");
      this.eyesStatus = d;
    } else {
      this.eyesStatus = null;
    }
  }
}
