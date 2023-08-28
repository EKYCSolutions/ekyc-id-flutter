import 'package:ekyc_id_flutter/core/document_scanner/document_scanner_result.dart';
import 'package:ekyc_id_flutter/core/models/api_result.dart';
import 'package:ekyc_id_flutter/core/services.dart';
import 'package:flutter/material.dart';
import 'package:json_view/json_view.dart';

class DocumentResult extends StatefulWidget {
  const DocumentResult({
    super.key,
    required this.mainSide,
    this.secondarySide,
  });

  final DocumentScannerResult mainSide;
  final DocumentScannerResult? secondarySide;

  @override
  State<DocumentResult> createState() => _DocumentResultState();
}

class _DocumentResultState extends State<DocumentResult> {
  bool isLoading = true;
  dynamic error;

  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();

    getData();
  }

  getData() async {
    try {
      ApiResult result = await EkycIDServices.instance.ocr(
        image: widget.mainSide.documentImage,
        objectType: widget.mainSide.documentType,
      );

      setState(() {
        isLoading = false;
        data = result.data;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Document Result"),
      ),
      body: CustomScrollView(
        slivers: [
          if (isLoading)
            SliverFillRemaining(
              child: Center(
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          if (!isLoading && error == null)
            SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    if (widget.secondarySide != null)
                      SizedBox(
                        height: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.memory(widget.mainSide.documentImage),
                            Image.memory(widget.secondarySide!.documentImage),
                          ],
                        ),
                      ),
                    if (widget.secondarySide == null)
                      SizedBox(
                        height: 120,
                        child: Image.memory(
                          widget.mainSide.documentImage,
                        ),
                      ),
                    Expanded(
                      child: JsonView(
                        json: data?["result"],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!isLoading && error != null)
            SliverFillRemaining(
              child: Center(
                  child: Text("Something went wrong! \n ${error.toString()}")),
            ),
        ],
      ),
    );
  }
}
