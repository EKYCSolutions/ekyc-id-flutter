import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'liveness_detection_values.dart';
import 'liveness_detection_controller.dart';

/// Class representing the native LivenessDetection view
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
      final Map<String, dynamic> creationParams = const <String, dynamic>{};

      return PlatformViewLink(
        viewType: "LivenessDetection",
        surfaceFactory: (
          BuildContext context,
          PlatformViewController controller,
        ) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          final ExpensiveAndroidViewController controller =
              PlatformViewsService.initExpensiveAndroidView(
            id: params.id,
            viewType: "LivenessDetection",
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          );
          controller
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener(onPlatformViewCreated)
            ..create();
          return controller;
        },
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
