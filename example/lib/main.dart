import 'package:ekyc_id_flutter/core/liveness_detection/liveness_detection_view.dart';
import 'package:ekyc_id_flutter/core/models/api_result.dart';
import 'package:ekyc_id_flutter/core/models/language.dart';
import 'package:ekyc_id_flutter/ekyc_id_express.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ekyc_id_flutter/core/services.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_result.dart';
import 'package:ekyc_id_flutter/core/liveness_detection/liveness_detection_result.dart';

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
    print("== ACCESS RESULTS HERE ==");

    ApiResult result = await EkycIDServices.instance.faceCompare(
      faceImage1: mainSide.faceImage,
      faceImage2: liveness.frontFace?.image,
    );

    print(result.data);
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
                // return DocumentScannerView(
                //     onDocumentScanned: ((
                //         {required mainSide, secondarySide}) async {}));
                return EkycIDExpress(
                  language: Language.EN,
                  onKYCCompleted: onKYCCompleted,
                );
                //return LivenessDetectionView(
                  //  onLivenessTestCompleted: (result) async {});
              },
            );
          },
          child: Text("Start KYC"),
        ),
      ),
    );
  }
}