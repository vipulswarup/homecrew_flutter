class DocumentUploadInit {
  const DocumentUploadInit({
    required this.documentId,
    required this.uploadUrl,
    required this.fileKey,
  });

  final String documentId;
  final String uploadUrl;
  final String fileKey;

  factory DocumentUploadInit.fromJson(Map<String, dynamic> json) {
    return DocumentUploadInit(
      documentId: json['document_id']?.toString() ?? '',
      uploadUrl: json['upload_url']?.toString() ?? '',
      fileKey: json['file_key']?.toString() ?? '',
    );
  }
}

