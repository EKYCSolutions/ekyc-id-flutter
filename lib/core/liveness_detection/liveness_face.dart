import 'dart:typed_data';

import 'liveness_detection_values.dart';

/// Class representing the face detection by the liveness detection camera.
class LivenessFace {
  /// The face image
  late Uint8List image;

  /// The probability that the left eye is open
  late double? leftEyeOpenProbability;

  /// The probability that the right eye is open
  late double? rightEyeOpenProbability;

  /// The head angle in the X direction
  late double? headEulerAngleX;

  /// The head angle in the Y direction
  late double? headEulerAngleY;

  /// The head angle in the Z direction
  late double? headEulerAngleZ;

  /// The head direction
  late FaceDetectionHeadDirection? headDirection;

  /// The eye status
  late FaceDetectionEyesStatus? eyesStatus;

  /// Creates an instance of LivenessFace from a [json] response.
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
