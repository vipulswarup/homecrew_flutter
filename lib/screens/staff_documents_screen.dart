import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_exception.dart';
import '../models/document_upload.dart';
import '../models/staff_document.dart';
import '../screens/document_preview_screen.dart';
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
  late Future<List<StaffDocument>> _load = widget.documentService.listForStaff(
    staffId: widget.staffId,
  );

  Future<void> _reload() async {
    setState(() {
      _load = widget.documentService.listForStaff(staffId: widget.staffId);
    });
  }

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

      DocumentService.logEvent('ui.file_selected', {
        'file_name': fileName,
        'path': path,
      });

      if (DocumentService.isHeicLike(fileName)) {
        final outPath = '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        toUpload = await DocumentService.convertHeicToJpegMac(
          input: toUpload,
          outputPath: outPath,
        );
        fileName = fileName.replaceAll(RegExp(r'\\.(heic|heif)$', caseSensitive: false), '.jpg');
        mime = 'image/jpeg';
        DocumentService.logEvent('ui.heic_converted', {
          'output_path': outPath,
          'file_name': fileName,
          'mime': mime,
        });
      }

      final bytes = await toUpload.readAsBytes();
      DocumentService.logEvent('ui.file_bytes_ready', {
        'file_name': fileName,
        'mime': mime,
        'bytes': bytes.length,
      });
      DocumentUploadInit init;
      try {
        init = await widget.documentService.createUploadUrl(
          householdId: widget.householdId,
          staffId: widget.staffId,
          fileName: fileName,
          fileType: mime,
          fileSize: bytes.length,
        );
      } catch (e) {
        throw StateError('upload-url failed: $e');
      }

      try {
        await widget.documentService.uploadToPresignedUrl(
          uploadUrl: init.uploadUrl,
          bytes: bytes,
          contentType: mime,
        );
      } catch (e) {
        throw StateError('PUT upload failed: $e');
      }

      setState(() {
        status = 'Uploaded. document_id=${init.documentId}';
      });
      await _reload();
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

  bool _isPreviewableInApp(StaffDocument doc) {
    final t = doc.fileType.toLowerCase();
    return t == 'application/pdf' || t == 'image/jpeg' || t == 'image/png';
  }

  Future<void> _openDoc(StaffDocument doc) async {
    setState(() {
      isLoading = true;
      status = null;
    });
    try {
      final downloadUrl =
          await widget.documentService.getDownloadUrl(documentId: doc.id);

      if (!_isPreviewableInApp(doc)) {
        final uri = Uri.parse(downloadUrl);
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok) {
          throw StateError('Could not open in external viewer');
        }
        return;
      }

      final bytes = await widget.documentService.downloadFromPresignedUrl(
        downloadUrl,
      );

      if (doc.fileType.toLowerCase() == 'application/pdf') {
        final file = File(
          '${Directory.systemTemp.path}/${doc.id}.pdf',
        );
        await file.writeAsBytes(bytes, flush: true);
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DocumentPreviewScreen.pdf(
              title: doc.fileName,
              file: file,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DocumentPreviewScreen.image(
              title: doc.fileName,
              imageBytes: bytes,
            ),
          ),
        );
      }
    } catch (e) {
      final message = e is ApiException ? e.message : e.toString();
      setState(() {
        status = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
      appBar: AppBar(
        title: Text('${widget.staffName} — Documents'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
        ],
      ),
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
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<StaffDocument>>(
                future: _load,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    final err = snapshot.error;
                    final message = err is ApiException ? err.message : '$err';
                    return Center(
                      child: Text(message, textAlign: TextAlign.center),
                    );
                  }
                  final docs = snapshot.data ?? const [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No documents uploaded yet.'));
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final canPreview = _isPreviewableInApp(doc);
                      final created =
                          doc.createdAt.toIso8601String().replaceFirst('T', ' ');
                      return ListTile(
                        title: Text(doc.fileName),
                        subtitle: Text('${doc.fileType} • ${doc.fileSize} B • $created'),
                        trailing: Icon(
                          canPreview ? Icons.visibility : Icons.open_in_new,
                        ),
                        onTap: isLoading ? null : () => _openDoc(doc),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

