import 'dart:io';

import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/document_upload.dart';

class DocumentService {
  DocumentService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<DocumentUploadInit> createUploadUrl({
    required String householdId,
    String? staffId,
    required String fileName,
    required String fileType,
    required int fileSize,
  }) async {
    final resp = await _api.post<Map<String, dynamic>>(
      '/documents/upload-url',
      data: {
        'household_id': householdId,
        'staff_id': staffId,
        'file_name': fileName,
        'file_type': fileType,
        'file_size': fileSize,
      },
    );
    final data = resp.data;
    if (data == null) throw StateError('Empty upload-url response');
    return DocumentUploadInit.fromJson(data);
  }

  Future<void> uploadToPresignedUrl({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) async {
    await _api.dio.put<void>(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        extra: {'skipAuth': true},
        headers: {'Content-Type': contentType},
      ),
    );
  }

  Future<String> getDownloadUrl({required String documentId}) async {
    final resp = await _api.get<Map<String, dynamic>>(
      '/documents/$documentId/download-url',
    );
    final data = resp.data;
    final url = data?['download_url']?.toString();
    if (url == null || url.isEmpty) throw StateError('Missing download_url');
    return url;
  }

  Future<List<int>> downloadFromPresignedUrl(String downloadUrl) async {
    final resp = await _api.dio.get<List<int>>(
      downloadUrl,
      options: Options(
        extra: {'skipAuth': true},
        responseType: ResponseType.bytes,
      ),
    );
    return resp.data ?? const [];
  }

  Future<void> delete({required String documentId}) async {
    await _api.delete<void>('/documents/$documentId');
  }

  static bool isHeicLike(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.heic') || lower.endsWith('.heif');
  }

  static Future<File> convertHeicToJpegMac({
    required File input,
    required String outputPath,
  }) async {
    final result = await Process.run(
      'sips',
      ['-s', 'format', 'jpeg', input.path, '--out', outputPath],
    );
    if (result.exitCode != 0) {
      throw StateError('HEIC conversion failed: ${result.stderr}');
    }
    final out = File(outputPath);
    if (!await out.exists()) {
      throw StateError('HEIC conversion produced no output');
    }
    return out;
  }
}

