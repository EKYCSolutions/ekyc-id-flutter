import 'dart:io';

import 'package:flutter/material.dart';
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
      return AndroidView(
        viewType: 'DocumentScanner',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: decorder,
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
