import 'package:ekyc_id_flutter/core/liveness_detection/liveness_detection_result.dart';
import 'package:flutter/material.dart';

class LivenessResult extends StatefulWidget {
  const LivenessResult({
    super.key,
    required this.livenessDetectionResult,
  });

  final LivenessDetectionResult livenessDetectionResult;

  @override
  State<LivenessResult> createState() => _LivenessResultState();
}

class _LivenessResultState extends State<LivenessResult> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liveness Result"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.livenessDetectionResult.leftFace != null)
                          Image.memory(
                              widget.livenessDetectionResult.leftFace!.image),
                        if (widget.livenessDetectionResult.frontFace != null)
                          Image.memory(
                              widget.livenessDetectionResult.frontFace!.image),
                        if (widget.livenessDetectionResult.rightFace != null)
                          Image.memory(
                              widget.livenessDetectionResult.rightFace!.image),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
