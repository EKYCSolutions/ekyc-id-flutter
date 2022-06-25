import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'liveness_detection_values.dart';
import 'liveness_detection_controller.dart';

class LivenessDetection extends StatefulWidget {
  const LivenessDetection({
    Key? key,
    required this.onCreated,
  }) : super(key: key);

  final LivenessDetectionCreatedCallback onCreated;

  @override
  State<LivenessDetection> createState() => _LivenessDetectionState();
}

class _LivenessDetectionState extends State<LivenessDetection> {
  Future<void> onPlatformViewCreated(id) async {
    widget.onCreated(LivenessDetectionController(id));
  }

  @override
  Widget build(BuildContext context) {
    StandardMessageCodec decorder = const StandardMessageCodec();

    if (Platform.isAndroid) {
      return AndroidView(
        viewType: 'LivenessDetection',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: decorder,
      );
    }

    if (Platform.isIOS) {
      return UiKitView(
        viewType: "LivenessDetection",
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: decorder,
      );
    }

    return Container(
      child: Text("Platform not Supported."),
    );
  }
}
