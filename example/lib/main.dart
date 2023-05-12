import 'package:ekyc_id_flutter/core/liveness_detection/liveness_detection_view.dart';
import 'package:ekyc_id_flutter/core/models/api_result.dart';
import 'package:ekyc_id_flutter/core/models/language.dart';
import 'package:ekyc_id_flutter/ekyc_id_express.dart';
import 'package:flutter/material.dart';
import 'package:ekyc_id_flutter/core/services.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_result.dart';
import 'package:ekyc_id_flutter/core/liveness_detection/liveness_detection_result.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  EkycIDServices.instance.setURL("SERVER_URL");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    Permission.camera.request();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
    ApiResult response = await EkycIDServices.instance
        .ocr(image: mainSide.documentImage, objectType: mainSide.documentType);

    print(response.data); // response object based on document type
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return EkycIDExpress(
                  language: Language.EN,
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
