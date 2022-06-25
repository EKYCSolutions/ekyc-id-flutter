import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_result.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> onDocumentScanned({
    DocumentScannerResult? mainSide,
    DocumentScannerResult? secondarySide,
  }) async {
    print("== Result ==");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('EkycID Flutter'),
        ),
        body: Container(
          color: Colors.blue,
          child: DocumentScannerView(
            onDocumentScanned: onDocumentScanned,
          ),
        ),
      ),
    );
  }
}
