import 'dart:typed_data';
import 'package:ekyc_id_flutter/core/models/api_result.dart';
import 'package:ekyc_id_flutter/core/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';

import '../document_scanner/document_scanner_result.dart';
import '../liveness_detection/liveness_detection_result.dart';
import 'document_image.dart';

class KYCResultCard extends StatefulWidget {
  const KYCResultCard({
    Key? key,
    this.mainSide,
    this.secondarySide,
    this.livenessDetectionResult,
  }) : super(key: key);

  final DocumentScannerResult? mainSide;
  final DocumentScannerResult? secondarySide;
  final LivenessDetectionResult? livenessDetectionResult;

  @override
  _KYCResultCardState createState() => _KYCResultCardState();
}

class _KYCResultCardState extends State<KYCResultCard> {
  List<Widget> _buildSectionTitle(
    String title, {
    Widget? action,
    bool showDivider = true,
    double titleSize = 14,
  }) {
    return [
      action == null
          ? Text(
              title,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: titleSize,
                  ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: titleSize,
                      ),
                ),
                action,
              ],
            ),
      showDivider
          ? Divider(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
            )
          : Material(),
    ];
  }

  Widget _buildFace({
    required String title,
    required List<int> face,
    required double width,
  }) {
    return Column(
      children: [
        Text(title),
        SizedBox(height: 10),
        Container(
          height: width * 1.5,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: MemoryImage(
                Uint8List.fromList(face),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDocumentImageSection() {
    List<Widget> temp = [];

    bool hasMainDocumentImage = widget.mainSide != null;
    bool hasSecondaryDocumentImage = widget.secondarySide != null;

    if (hasMainDocumentImage || hasSecondaryDocumentImage) {
      temp.addAll([
        SizedBox(height: 20),
        ..._buildSectionTitle(
          "document_images",
        )
      ]);
    }

    if (hasMainDocumentImage) {
      temp.addAll([
        ..._buildSectionTitle(
          "front",
          showDivider: false,
          titleSize: 12,
          action: IconButton(
            onPressed: () {
              // AppUtils.shareImage(widget.mainSide!.documentImage);
            },
            icon: Icon(
              AntDesign.save,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        DocumentImage(image: widget.mainSide!.documentImage),
      ]);
    }

    if (hasSecondaryDocumentImage) {
      temp.addAll([
        ..._buildSectionTitle(
          "back".toUpperCase(),
          showDivider: false,
          titleSize: 12,
          action: IconButton(
            onPressed: () {
              // AppUtils.shareImage(widget.secondarySide!.documentImage);
            },
            icon: Icon(
              AntDesign.save,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        DocumentImage(image: widget.secondarySide!.documentImage),
      ]);
    }
    return temp;
  }

  List<Widget> _buildFaceImagesSection() {
    // AppProvider appProvider = Provider.of(context);
    // Map<String?, String?> lang = appProvider.lang;

    final mq = MediaQuery.of(context);
    double photoWidth = (mq.size.width - 40 - 15) / 4;
    if (widget.livenessDetectionResult != null) {
      List<Widget> row = [];

      if (widget.mainSide != null) {
        row.addAll([
          _buildFace(
            face: widget.mainSide!.faceImage!,
            width: photoWidth,
            title: "card",
          ),
          SizedBox(width: 5),
        ]);
      }

      if (widget.livenessDetectionResult!.leftFace != null) {
        row.addAll([
          _buildFace(
            face: widget.livenessDetectionResult!.leftFace!.image,
            width: photoWidth,
            title: "left",
          ),
          SizedBox(width: 5),
        ]);
      }

      if (widget.livenessDetectionResult!.frontFace != null) {
        row.addAll([
          _buildFace(
            face: widget.livenessDetectionResult!.frontFace!.image,
            width: photoWidth,
            title: "front",
          ),
          SizedBox(width: 5),
        ]);
      }

      if (widget.livenessDetectionResult!.rightFace != null) {
        row.add(_buildFace(
          face: widget.livenessDetectionResult!.rightFace!.image,
          width: photoWidth,
          title: "right",
        ));
      }

      if (row.length != 0) {
        return [
          SizedBox(height: 20),
          ..._buildSectionTitle("face_images".toUpperCase()),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: row),
        ];
      }

      return [];
    }

    return [];
  }

  List<Widget> _buildDocumentInfoSection() {
    // AppProvider appProvider = Provider.of(context);
    // Map<String?, String?> lang = appProvider.lang;

    if (widget.mainSide != null) {
      return [
        SizedBox(height: 20),
        ..._buildSectionTitle("document_info".toUpperCase()),
        // OCRResultSection(
        //   image: widget.mainSide!.documentImage,
        //   objectType: widget.mainSide!.documentType,
        //   group: widget.mainSide!.documentGroup,
        // ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    // AppProvider appProvider = Provider.of(context);
    // Map<String?, String?> lang = appProvider.lang;
    int numSuccesses = widget.livenessDetectionResult!.prompts
        .where((element) {
          return element.success != null && element.success!;
        })
        .toList()
        .length;
    double livenessScore =
        numSuccesses / widget.livenessDetectionResult!.prompts.length;
    final mq = MediaQuery.of(context);
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20),
          // Row(
          //   children: [
          //     Expanded(
          //       child: FutureBuilder<ApiResult>(
          //         future: EkycIDServices.instance.faceCompare(
          //           faceImage1: widget.mainSide!.faceImage ?? null,
          //           faceImage2: () {
          //             if (widget.livenessDetectionResult!.frontFace != null) {
          //               return widget.livenessDetectionResult!.frontFace!.image;
          //             } else if (widget.livenessDetectionResult!.leftFace !=
          //                 null) {
          //               return widget.livenessDetectionResult!.leftFace!.image;
          //             } else if (widget.livenessDetectionResult!.rightFace !=
          //                 null) {
          //               return widget.livenessDetectionResult!.rightFace!.image;
          //             }

          //             return null;
          //           }(),
          //         ),
          //         builder: (
          //           BuildContext context,
          //           AsyncSnapshot<ApiResult> snapshot,
          //         ) {
          //           if (snapshot.hasError) {
          //             print(snapshot.error);
          //             return Row(
          //               children: [
          //                 // KYCSummaryIcon(
          //                 //   icon: MaterialCommunityIcons.face_recognition,
          //                 // ),
          //                 SizedBox(width: 10),
          //                 // Expanded(
          //                 //   child: Column(
          //                 //     crossAxisAlignment: CrossAxisAlignment.start,
          //                 //     children: [
          //                 //       Text(
          //                 //         lang["face_match_error"]!,
          //                 //         style: Theme.of(context)
          //                 //             .textTheme
          //                 //             .bodyText1!
          //                 //             .copyWith(
          //                 //               color: Theme.of(context)
          //                 //                   .colorScheme
          //                 //                   .onBackground,
          //                 //               fontWeight: FontWeight.normal,
          //                 //               fontSize: 12,
          //                 //             ),
          //                 //       ),
          //                 //     ],
          //                 //   ),
          //                 // ),
          //               ],
          //             );
          //           }

          //           if (snapshot.hasData) {
          //             return Row(
          //               children: [
          //                 KYCSummaryIcon(
          //                   icon: MaterialCommunityIcons.face_recognition,
          //                   score: snapshot.data!,
          //                 ),
          //                 SizedBox(width: 10),
          //                 Expanded(
          //                   child: Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     children: [
          //                       Text(
          //                         snapshot.data! >=
          //                                 appProvider.faceCompareThreshold
          //                             ? lang["matched"]!
          //                             : lang["not_matched"]!,
          //                         style: Theme.of(context)
          //                             .textTheme
          //                             .bodyText1!
          //                             .copyWith(
          //                               color: Theme.of(context)
          //                                   .colorScheme
          //                                   .onBackground,
          //                               fontSize: 12,
          //                               fontWeight: FontWeight.bold,
          //                             ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ],
          //             );
          //           }

          //           return Row(
          //             children: [
          //               KYCSummaryIcon(
          //                   icon: MaterialCommunityIcons.face_recognition),
          //               SizedBox(width: 10),
          //               Expanded(
          //                 child: Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //                     Text(
          //                       "--",
          //                       style: Theme.of(context)
          //                           .textTheme
          //                           .bodyText1!
          //                           .copyWith(
          //                             color: Theme.of(context)
          //                                 .colorScheme
          //                                 .onBackground,
          //                             fontSize: 24,
          //                             fontWeight: FontWeight.bold,
          //                           ),
          //                     ),
          //                     Text(
          //                       lang["face_matching"]!,
          //                       style: Theme.of(context)
          //                           .textTheme
          //                           .bodyText1!
          //                           .copyWith(
          //                             color: Theme.of(context)
          //                                 .colorScheme
          //                                 .onBackground,
          //                             fontWeight: FontWeight.normal,
          //                             fontSize: 12,
          //                           ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ],
          //           );
          //         },
          //       ),
          //     ),
          //     SizedBox(width: 10),
          //     Expanded(
          //       child: Row(
          //         children: [
          //           KYCSummaryIcon(
          //             icon: Ionicons.person_outline,
          //             score: livenessScore,
          //           ),
          //           SizedBox(width: 10),
          //           Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text(
          //                 "$numSuccesses/${widget.livenessDetectionResult!.prompts.length}",
          //                 style: Theme.of(context).textTheme.bodyText1!.copyWith(
          //                       color: Theme.of(context).colorScheme.onBackground,
          //                       fontSize: 24,
          //                       fontWeight: FontWeight.bold,
          //                     ),
          //               ),
          //               Text(
          //                 lang["liveness_score"]!,
          //                 style: Theme.of(context).textTheme.bodyText1!.copyWith(
          //                       color: Theme.of(context).colorScheme.onBackground,
          //                       fontWeight: FontWeight.normal,
          //                       fontSize: 12,
          //                     ),
          //               ),
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          ..._buildFaceImagesSection(),
          ..._buildDocumentInfoSection(),
          ..._buildDocumentImageSection(),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
