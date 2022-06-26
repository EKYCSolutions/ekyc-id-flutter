import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:ekyc_id_flutter/core/services.dart';
import 'package:ekyc_id_flutter/ekyc_id_express.dart';
import 'package:ekyc_id_flutter/core/models/language.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_result.dart';
import 'package:ekyc_id_flutter/core/liveness_detection/liveness_detection_result.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  EkycIDServices.instance.setURL("https://eekyc-server.demo.ekycsolutions.com");
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> onKYCCompleted({
    required LivenessDetectionResult liveness,
    required DocumentScannerResult mainSide,
    DocumentScannerResult? secondarySide,
  }) async {
    print("== ACCESS RESULTS HERE ==");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            await showCupertinoModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return EkycIDExpress(
                  language: Language.KH,
                  onKYCCompleted: onKYCCompleted,
                );
              },
            );
          },
          child: Text("Start KYC"),
        ),
      ),
    );
  }
}
