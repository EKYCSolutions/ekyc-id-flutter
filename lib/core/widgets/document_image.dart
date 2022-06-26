import 'dart:typed_data';
import 'package:flutter/material.dart';

class DocumentImage extends StatefulWidget {
  const DocumentImage({
    Key? key,
    required this.image,
  }) : super(key: key);

  final List<int> image;

  @override
  _DocumentImageState createState() => _DocumentImageState();
}

class _DocumentImageState extends State<DocumentImage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (
      BuildContext context,
      BoxConstraints constraints,
    ) {
      return Container(
        width: constraints.maxWidth,
        height: constraints.maxWidth * 0.56,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: MemoryImage(Uint8List.fromList(widget.image)),
          ),
        ),
      );
    });
  }
}
