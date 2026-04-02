import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentPreviewScreen extends StatelessWidget {
  const DocumentPreviewScreen.pdf({
    super.key,
    required this.title,
    required this.file,
  })  : imageBytes = null,
        _isPdf = true;

  const DocumentPreviewScreen.image({
    super.key,
    required this.title,
    required this.imageBytes,
  })  : file = null,
        _isPdf = false;

  final String title;
  final File? file;
  final List<int>? imageBytes;
  final bool _isPdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _isPdf
          ? SfPdfViewer.file(file!)
          : InteractiveViewer(
              child: Center(
                child: Image.memory(
                  Uint8List.fromList(imageBytes!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
    );
  }
}

