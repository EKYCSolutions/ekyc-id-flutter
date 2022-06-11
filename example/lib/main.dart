import 'package:flutter/material.dart';
import 'package:ekyc_id_flutter/models/frame_status.dart';
import 'package:ekyc_id_flutter/liveness_detection/liveness_detection.dart';
import 'package:ekyc_id_flutter/liveness_detection/liveness_detection_values.dart';
import 'package:ekyc_id_flutter/liveness_detection/liveness_detection_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isInitialized = false;
  // late DocumentScannerController controller;
  late LivenessDetectionController controller;

  @override
  void initState() {
    super.initState();
  }

  void onLivenessDetectionCreated(
      LivenessDetectionController controller) async {
    this.controller = controller;
    await this.controller.start(
          onFrame: onFrame,
          onInitialized: onInitialized,
          onAllPromptsCompleted: onAllPromptCompleted,
          onPromptCompleted: onPromptCompleted,
          onFocus: onFocus,
          onFocusDropped: onFocusDropped,
        );
  }

  void onFrame(FrameStatus frameStatus) {
    print("onFrame: $frameStatus");
  }

  void onFocus() {
    print("onFocus");
  }

  void onFocusDropped() {
    print("onFocusDropped");
  }

  void onPromptCompleted({
    required int currentPromptIndex,
    required double progress,
    required bool success,
  }) {}

  void onAllPromptCompleted(LivenessDetectionResult result) {}

  // void onDetection(DocumentScannerResult result) {
  //   print("onDetection: ${result.documentType}");
  // }

  void onInitialized() {
    setState(() {
      isInitialized = true;
    });
    print("onInitialized");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          color: Colors.blue,
          child: LivenessDetection(
            onCreated: onLivenessDetectionCreated,
          ),
        ),
      ),
    );
  }
}
