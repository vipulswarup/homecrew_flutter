class StaffDocument {
  const StaffDocument({
    required this.id,
    required this.householdId,
    required this.staffId,
    required this.fileKey,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.createdAt,
  });

  final String id;
  final String householdId;
  final String staffId;
  final String fileKey;
  final String fileName;
  final String fileType;
  final int fileSize;
  final DateTime createdAt;

  factory StaffDocument.fromJson(Map<String, dynamic> json) {
    return StaffDocument(
      id: json['id']?.toString() ?? '',
      householdId: json['household_id']?.toString() ?? '',
      staffId: json['staff_id']?.toString() ?? '',
      fileKey: json['file_key']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      fileType: json['file_type']?.toString() ?? 'application/octet-stream',
      fileSize: int.tryParse(json['file_size']?.toString() ?? '') ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

