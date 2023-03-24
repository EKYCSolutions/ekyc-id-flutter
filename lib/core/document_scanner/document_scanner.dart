import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'document_scanner_values.dart';
import 'document_scanner_controller.dart';

/// Class representing the native DocumentScanner view
class DocumentScanner extends StatefulWidget {
  const DocumentScanner({
    Key? key,
    required this.onCreated,
  }) : super(key: key);

  final DocumentScannerCreatedCallback onCreated;

  @override
  State<DocumentScanner> createState() => _DocumentScannerState();
}

class _DocumentScannerState extends State<DocumentScanner> {
  Future<void> onPlatformViewCreated(id) async {
    widget.onCreated(DocumentScannerController(id));
  }

  @override
  Widget build(BuildContext context) {
    StandardMessageCodec decorder = const StandardMessageCodec();

    if (Platform.isAndroid) {
      final Map<String, dynamic> creationParams = const <String, dynamic>{};

      return PlatformViewLink(
        viewType: "DocumentScanner",
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
            viewType: "DocumentScanner",
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
        viewType: "DocumentScanner",
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: decorder,
      );
    }

    return Container(
      child: Text("Platform not Supported."),
    );
  }
}
