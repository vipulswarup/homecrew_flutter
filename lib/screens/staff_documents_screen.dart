import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../services/document_service.dart';

class StaffDocumentsScreen extends StatefulWidget {
  const StaffDocumentsScreen({
    super.key,
    required this.documentService,
    required this.householdId,
    required this.staffId,
    required this.staffName,
  });

  final DocumentService documentService;
  final String householdId;
  final String staffId;
  final String staffName;

  @override
  State<StaffDocumentsScreen> createState() => _StaffDocumentsScreenState();
}

class _StaffDocumentsScreenState extends State<StaffDocumentsScreen> {
  bool isLoading = false;
  String? status;

  Future<void> _pickAndUpload() async {
    setState(() {
      isLoading = true;
      status = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(withData: false);
      final file = result?.files.singleOrNull;
      if (file == null) return;
      final path = file.path;
      if (path == null) throw StateError('Selected file has no path');

      File toUpload = File(path);
      String fileName = file.name;
      String mime = _guessMime(fileName);

      if (DocumentService.isHeicLike(fileName)) {
        final outPath = '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        toUpload = await DocumentService.convertHeicToJpegMac(
          input: toUpload,
          outputPath: outPath,
        );
        fileName = fileName.replaceAll(RegExp(r'\\.(heic|heif)$', caseSensitive: false), '.jpg');
        mime = 'image/jpeg';
      }

      final bytes = await toUpload.readAsBytes();
      final init = await widget.documentService.createUploadUrl(
        householdId: widget.householdId,
        staffId: widget.staffId,
        fileName: fileName,
        fileType: mime,
        fileSize: bytes.length,
      );

      await widget.documentService.uploadToPresignedUrl(
        uploadUrl: init.uploadUrl,
        bytes: bytes,
        contentType: mime,
      );

      setState(() {
        status = 'Uploaded. document_id=${init.documentId}';
      });
    } catch (e) {
      final message = e is ApiException ? e.message : e.toString();
      setState(() {
        status = message;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _guessMime(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'application/octet-stream';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.staffName} — Documents')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : _pickAndUpload,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Pick file and upload'),
            ),
            const SizedBox(height: 16),
            if (status != null) Text(status!),
          ],
        ),
      ),
    );
  }
}

