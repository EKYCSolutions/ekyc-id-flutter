import 'dart:typed_data';

import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_options.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_values.dart';
import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_view.dart';
import 'package:ekyc_id_flutter/core/liveness_detection/liveness_detection_options.dart';
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
  EkycIDServices.instance.setURL("https://test-service.ews.ekycsolutions.com");
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
  Uint8List? livenessImage;
  Uint8List? docImage;

  Language currentLanguage = Language.KH;

  Future<void> onKYCCompleted({
    required LivenessDetectionResult liveness,
    required DocumentScannerResult mainSide,
    DocumentScannerResult? secondarySide,
  }) async {
    print("mainSide ${mainSide.documentImage}");
    print("objectType ${mainSide.documentType}");

    ApiResult response = await EkycIDServices.instance
        .ocr(image: mainSide.documentImage, objectType: mainSide.documentType);

    print(response.data); // response object based on document type

    setState(() {
      livenessImage = liveness.frontFace!.image;
      docImage = mainSide.documentImage;
    });
    Navigator.of(context).pop();
  }

  Future<void> onDocumentScanned({
    required DocumentScannerResult mainSide,
    DocumentScannerResult? secondarySide,
  }) async {
    Navigator.of(context).pop();
  }

  Future<void> onLivenessTestCompleted(
      LivenessDetectionResult livenessDetectionResult) async {
    Navigator.of(context).pop();
  }

  Future<void> onFaceCompareComplete({
    required LivenessDetectionResult liveness,
    required DocumentScannerResult mainSide,
    DocumentScannerResult? secondarySide,
  }) async {
    ApiResult response = await EkycIDServices.instance.faceCompare(
      faceImage1: mainSide.faceImage,
      faceImage2: liveness.frontFace?.image,
    );
    print('---------match score: ${response.data}'); // match score
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 60,
              margin: const EdgeInsets.only(bottom: 20),
              child: DropdownButton<Language>(
                value: currentLanguage,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                underline: Container(
                  height: 2,
                  color: Colors.blue,
                ),
                onChanged: (Language? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    currentLanguage = value!;
                  });
                },
                items: [
                  DropdownMenuItem<Language>(
                    value: Language.KH,
                    child: Text("ខ្មែរ"),
                  ),
                  DropdownMenuItem<Language>(
                    value: Language.EN,
                    child: Text("English"),
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: 300,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return EkycIDExpress(
                        language: currentLanguage,
                        onKYCCompleted: onKYCCompleted,
                      );
                    },
                  );
                },
                child: Text("EKYC Express"),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: 300,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return LivenessDetectionView(
                        onLivenessTestCompleted: onLivenessTestCompleted,
                        language: currentLanguage,
                        options: const LivenessDetectionOptions(
                          promptTimerCountDownSec: 5,
                        ),
                      );
                    },
                  );
                },
                child: Text("Liveness Detection"),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: 300,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return DocumentScannerView(
                        onDocumentScanned: onDocumentScanned,
                        language: Language.KH,
                        options: const DocumentScannerOptions(
                          scannableDocuments: [
                            ScannableDocument(
                              mainSide: ObjectDetectionObjectType.NATIONAL_ID_0,
                              secondarySide:
                                  ObjectDetectionObjectType.NATIONAL_ID_0_BACK,
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text("Document Detection"),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: 300,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return EkycIDExpress(
                          language: currentLanguage,
                          onKYCCompleted: onFaceCompareComplete);
                    },
                  );
                },
                child: Text("Face Compare"),
              ),
            ),
            // if (livenessImage != null)
            //   Image.memory(
            //     livenessImage!,
            //     height: 200,
            //   ),
            // if (docImage != null)
            //   Image.memory(
            //     docImage!,
            //     height: 200,
            //   ),
          ],
        ),
      ),
    );
  }
}
