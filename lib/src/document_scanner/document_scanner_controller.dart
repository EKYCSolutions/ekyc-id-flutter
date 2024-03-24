import 'package:flutter/services.dart';

import '../core/models/frame_status.dart';
import 'document_scanner_values.dart';

/// Class for controlling the document scanner functionalites.
class DocumentScannerController {
  late MethodChannel _methodChannel;
  late EventChannel _eventChannel;

  DocumentScannerController(int id) {
    _methodChannel = new MethodChannel('DocumentScanner_MethodChannel_$id');
    _eventChannel = new EventChannel('DocumentScanner_EventChannel_$id');
  }

  /// Initializes the camera and starts the scanning process.
  ///
  Future<void> start({
    required void Function() onInitialized,
    required void Function(DocumentSide) onCurrentSideChanged,
    required void Function(FrameStatus) onFrameStatusChanged,
    required void Function(int, int) onCaptureCountDownChanged,
    required Future<void> Function(
            DocumentScannerResult, DocumentScannerResult?)
        onDocumentScanned,
    required DocumentScannerOptions options,
  }) async {
    await _methodChannel.invokeMethod('start', options.toMap());
    _registerEventListener(
        onInitialized: onInitialized,
        onDocumentScanned: onDocumentScanned,
        onFrameStatusChanged: onFrameStatusChanged,
        onCurrentSideChanged: onCurrentSideChanged,
        onCaptureCountDownChanged: onCaptureCountDownChanged);
  }

  /// Stops the scanning process and dispose the camera object.
  Future<void> dispose() async {
    await _methodChannel.invokeMethod('dispose');
  }

  /// Allows the camera to start processing the next frame.
  Future<void> nextImage() async {
    await _methodChannel.invokeMethod('nextImage');
  }

  Future<void> reset() async {
    await _methodChannel.invokeMethod('reset');
  }

  void _registerEventListener({
    required void Function() onInitialized,
    required void Function(DocumentSide) onCurrentSideChanged,
    required void Function(FrameStatus) onFrameStatusChanged,
    required void Function(int, int) onCaptureCountDownChanged,
    required Future<void> Function(
            DocumentScannerResult, DocumentScannerResult?)
        onDocumentScanned,
  }) {
    _eventChannel.receiveBroadcastStream().listen((event) async {
      if (event["type"] == "onDocumentScanned") {
        DocumentScannerResult mainSide = DocumentScannerResult.fromMap(
            Map<String, dynamic>.from(event["values"]["mainSide"]));
        DocumentScannerResult? secondarySide =
            event["values"]["secondarySide"] != null
                ? DocumentScannerResult.fromMap(
                    Map<String, dynamic>.from(event["values"]["secondarySide"]))
                : null;
        onDocumentScanned(mainSide, secondarySide);
        return;
      }

      if (event["type"] == "onInitialized") {
        onInitialized();
        return;
      }

      if (event["type"] == "onCurrentSideChanged") {
        DocumentSide side = DocumentSide.values.firstWhere(
            (e) => e.toString() == "DocumentSide.${event['values']}");
        onCurrentSideChanged(side);
        return;
      }

      if (event["type"] == "onFrameStatusChanged") {
        FrameStatus frameStatus = FrameStatus.values.firstWhere(
            (e) => e.toString() == "FrameStatus.${event['values']}");
        onFrameStatusChanged(frameStatus);
        return;
      }

      if (event["type"] == "onCaptureCountDownChanged") {
        onCaptureCountDownChanged(
          event["values"]["current"],
          event["values"]["max"],
        );
        return;
      }
    });
  }
}
