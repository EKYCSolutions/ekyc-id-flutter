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
          onFocus: onFocus,
          onInitialized: onInitialized,
          onFocusDropped: onFocusDropped,
          onPromptCompleted: onPromptCompleted,
          onCountDownChanged: onCountDownChanged,
          onAllPromptsCompleted: onAllPromptCompleted,
          options: LivenessDetectionOptions(),
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
    required int completedPromptIndex,
    required bool success,
    required double progress,
  }) {}

  void onAllPromptCompleted(LivenessDetectionResult result) {}

  void onCountDownChanged({
    required int current,
    required int max,
  }) {
    print("max: $max");
    print("current: $current");
  }

  void onInitialized() {
    setState(() {
      isInitialized = true;
    });
    print("onInitialized");
  }

  @override
  void dispose() {
    this.controller.dispose();
    super.dispose();
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
