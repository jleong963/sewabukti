import 'dart:typed_data';

import 'package:sewabukti/src/core/constants/app_limits.dart';

/// Metadata for one uploaded evidence file (mirrors `evidence_files`).
class EvidenceFile {
  const EvidenceFile({
    required this.id,
    required this.category,
    required this.originalFilename,
    required this.mimeType,
    required this.sizeBytes,
    required this.uploadedAt,
    this.title,
    this.description,
    this.documentDate,
    this.sha256Hash,
  });

  final String id;
  final String category; // EvidenceCategory.code
  final String originalFilename;
  final String mimeType;
  final int sizeBytes;
  final String uploadedAt;
  final String? title;
  final String? description;
  final String? documentDate;
  final String? sha256Hash;

  bool get isImage => mimeType.startsWith('image/');

  factory EvidenceFile.fromJson(Map<String, dynamic> json) => EvidenceFile(
    id: (json['id'] ?? '').toString(),
    category: (json['category'] ?? 'other').toString(),
    originalFilename: (json['original_filename'] ?? '').toString(),
    mimeType: (json['mime_type'] ?? 'application/octet-stream').toString(),
    sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
    uploadedAt: (json['uploaded_at'] ?? '').toString(),
    title: json['title'] as String?,
    description: json['description'] as String?,
    documentDate: json['document_date'] as String?,
    sha256Hash: json['sha256_hash'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'category': category,
    'original_filename': originalFilename,
    'mime_type': mimeType,
    'size_bytes': sizeBytes,
    'uploaded_at': uploadedAt,
    'title': title,
    'description': description,
    'document_date': documentDate,
    'sha256_hash': sha256Hash,
  };
}

/// A file chosen by the user, ready to validate and upload.
class PickedEvidence {
  const PickedEvidence({
    required this.name,
    required this.bytes,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String name;
  final Uint8List bytes;
  final String mimeType;
  final int sizeBytes;
}

/// Result of requesting a preview: either in-memory [bytes] (demo) or a
/// short-lived signed [url] (backend).
class EvidencePreview {
  const EvidencePreview({this.bytes, this.url, required this.mimeType});

  final Uint8List? bytes;
  final String? url;
  final String mimeType;

  bool get isImage => mimeType.startsWith('image/');
  bool get isAvailable => bytes != null || url != null;
}

const Map<String, String> _mimeByExtension = <String, String>{
  'pdf': 'application/pdf',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'webp': 'image/webp',
  'txt': 'text/plain',
};

/// Maps a file extension to a supported MIME type, or null if unsupported.
String? mimeForExtension(String? extension) =>
    _mimeByExtension[(extension ?? '').toLowerCase()];

/// Per-type size ceiling in bytes (§12.2).
int perFileLimitBytes(String mimeType) {
  if (mimeType == 'application/pdf') return StorageLimits.maxPdfBytes;
  if (mimeType == 'text/plain') return StorageLimits.maxImageBytes;
  return StorageLimits.maxImageBytes; // images
}

/// Validates a picked file against type and quota limits; returns a stable
/// error code or null when acceptable.
String? validatePickedEvidence(
  PickedEvidence file, {
  required int currentCount,
  required int currentTotalBytes,
}) {
  if (!kSupportedEvidenceMimeTypes.contains(file.mimeType)) {
    return 'unsupported_type';
  }
  if (file.sizeBytes <= 0 ||
      file.sizeBytes > perFileLimitBytes(file.mimeType)) {
    return 'file_too_large';
  }
  if (currentCount + 1 > StorageLimits.maxFilesPerCase) {
    return 'file_count_exceeded';
  }
  if (currentTotalBytes + file.sizeBytes >
      StorageLimits.totalEvidenceBytesPerCase) {
    return 'storage_quota_exceeded';
  }
  return null;
}
