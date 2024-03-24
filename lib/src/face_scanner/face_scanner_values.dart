class FaceScannerCameraOptions {
  final double roiSize;
  final double faceCropScale;
  final int captureDurationCountDown;
  final double minFaceWidthPercentage;
  final double maxFaceWidthPercentage;

  const FaceScannerCameraOptions({
    this.roiSize = 250,
    this.faceCropScale = 1.4,
    this.maxFaceWidthPercentage = 1,
    this.minFaceWidthPercentage = 0.7,
    this.captureDurationCountDown = 3,
  });

  Map<String, dynamic> toMap() {
    return {
      "roiSize": roiSize,
      "faceCropScale": faceCropScale,
      "maxFaceWidthPercentage": maxFaceWidthPercentage,
      "minFaceWidthPercentage": minFaceWidthPercentage,
      "captureDurationCountDown": captureDurationCountDown,
    };
  }
}

/// Class representing configurations of the [DocumentScanner].
class FaceScannerOptions {
  final bool useFrontCamera;
  final FaceScannerCameraOptions cameraOptions;

  const FaceScannerOptions({
    this.useFrontCamera = false,
    this.cameraOptions = const FaceScannerCameraOptions(),
  });

  Map<String, dynamic> toMap() {
    return {
      "useFrontCamera": useFrontCamera,
      "cameraOptions": cameraOptions.toMap(),
    };
  }
}
