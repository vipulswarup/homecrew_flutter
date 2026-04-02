import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../models/document_upload.dart';
import '../models/staff_document.dart';

class DocumentService {
  DocumentService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  static void logEvent(String name, Map<String, Object?> fields) {
    debugPrint('[doc_upload] $name ${fields.map((k, v) => MapEntry(k, v))}');
  }

  static String redactUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '<invalid-url>';
    return uri.replace(query: '<redacted>').toString();
  }

  Future<DocumentUploadInit> createUploadUrl({
    required String householdId,
    String? staffId,
    required String fileName,
    required String fileType,
    required int fileSize,
  }) async {
    logEvent('create_upload_url.request', {
      'household_id': householdId,
      'staff_id': staffId,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
    });
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
    final init = DocumentUploadInit.fromJson(data);
    logEvent('create_upload_url.response', {
      'document_id': init.documentId,
      'file_key': init.fileKey,
      'upload_url': redactUrl(init.uploadUrl),
    });
    return init;
  }

  Future<List<StaffDocument>> listForStaff({required String staffId}) async {
    final resp = await _api.get<dynamic>('/staff/$staffId/documents');
    final data = resp.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => StaffDocument.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  Future<void> uploadToPresignedUrl({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) async {
    final payload = Uint8List.fromList(bytes);
    logEvent('put_presigned.request', {
      'upload_url': redactUrl(uploadUrl),
      'content_type': contentType,
      'content_length': payload.length,
      'sse': 'AES256',
    });
    try {
      final resp = await _api.dio.put<void>(
        uploadUrl,
        data: payload,
        options: Options(
          extra: {'skipAuth': true},
          headers: {
            'Content-Type': contentType,
            'Content-Length': payload.length,
            'x-amz-server-side-encryption': 'AES256',
          },
        ),
      );
      logEvent('put_presigned.response', {
        'upload_url': redactUrl(uploadUrl),
        'status': resp.statusCode,
      });
    } on DioException catch (e) {
      logEvent('put_presigned.error', {
        'upload_url': redactUrl(uploadUrl),
        'status': e.response?.statusCode,
        'request_method': e.requestOptions.method,
        'request_uri': e.requestOptions.uri.toString(),
        'request_headers': e.requestOptions.headers,
        'response_headers': e.response?.headers.map,
        'response_data_type': e.response?.data.runtimeType.toString(),
        'response_data': e.response?.data,
        'error_type': e.type.toString(),
        'message': e.message,
      });
      rethrow;
    }
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

