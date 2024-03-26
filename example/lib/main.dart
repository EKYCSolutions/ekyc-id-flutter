import 'package:ekyc_id_flutter/ekyc_id.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ekyc_id_flutter/src/core/document_detection.dart';
import 'package:ekyc_id_flutter/src/document_scanner/document_scanner_values.dart';
import 'package:ekyc_id_flutter/src/core/models/object_detection_object_type.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  // var faceDetector = FaceDetectionController();
  // var documentDetector = DocumentDetectionController();

  @override
  void initState() {
    super.initState();
    // documentDetector.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            // final ImagePicker picker = ImagePicker();

            // final XFile? image =
            //     await picker.pickImage(source: ImageSource.gallery);
            // var bytes = await image?.readAsBytes();

            // if (bytes != null) {
            //   await documentDetector.setWhiteList([
            //     ObjectDetectionObjectType.NATIONAL_ID_0,
            //   ]);
            //   List<DocumentScannerResult> detections =
            //       await documentDetector.detect(bytes);

            //   if (detections.isNotEmpty) {
            //     showDialog(
            //       context: context,
            //       builder: (BuildContext context) {
            //         return Dialog(
            //           child: Image.memory(detections[0].documentImage),
            //         );
            //       },
            //     );
            //   }
            // }
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                // return FaceScannerView(
                //   onFaceScanned: (face) async {
                //     print(face.toString());
                //   },
                // );
                return DocumentScannerView(
                  onDocumentScanned: (mainSide, secondarySide) async {
                    print(mainSide.toString());
                    print(secondarySide?.toString());
                  },
                  options: DocumentScannerOptions(scannableDocuments: [
                    ScannableDocument(
                      mainSide: ObjectDetectionObjectType.NATIONAL_ID_0,
                    )
                  ]),
                  overlayBuilder: (BuildContext context,
                      FrameStatus frameStatus,
                      DocumentSide side,
                      int countDown) {
                    return Container(
                      child: Center(
                          child: Text("$frameStatus, $side, $countDown")),
                    );
                  },
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
