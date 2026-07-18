import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sewabukti/src/core/auth/auth_controller.dart';
import 'package:sewabukti/src/core/config/app_config.dart';
import 'package:sewabukti/src/core/preferences/preferences_providers.dart';
import 'package:sewabukti/src/features/evidence/evidence_category.dart';
import 'package:sewabukti/src/features/evidence/evidence_file.dart';

class EvidenceException implements Exception {
  const EvidenceException(this.code);
  final String code;
  @override
  String toString() => 'EvidenceException($code)';
}

abstract interface class EvidenceRepository {
  Future<List<EvidenceFile>> list(String caseId);
  Future<EvidenceFile> upload({
    required String caseId,
    required EvidenceCategory category,
    required PickedEvidence file,
    String? title,
    String? description,
    String? documentDate,
  });
  Future<EvidencePreview> preview(EvidenceFile evidence);
  Future<String?> downloadUrl(EvidenceFile evidence);

  /// Raw bytes for an evidence file, or null if unavailable. Used to embed
  /// images into the client-side evidence bundle (§10.8); never uploaded back.
  Future<Uint8List?> fetchBytes(EvidenceFile evidence);
  Future<void> delete(EvidenceFile evidence);
}

/// Backend repository: uploads via short-lived signed URLs and reads via
/// signed download URLs, all authorised by the Google ID token (§12.1).
class RemoteEvidenceRepository implements EvidenceRepository {
  RemoteEvidenceRepository(this._ref);

  final Ref _ref;

  Uri _fn(String name) =>
      Uri.parse('${AppConfig.supabaseUrl}/functions/v1/$name');

  Map<String, String> _headers() {
    final String? token = _ref.read(authControllerProvider).idToken;
    if (token == null) throw const EvidenceException('not_authenticated');
    return <String, String>{
      'Authorization': 'Bearer $token',
      'apikey': AppConfig.supabaseAnonKey,
      'Content-Type': 'application/json',
    };
  }

  Future<http.Response> _post(String fn, Map<String, dynamic> body) async {
    try {
      return await http.post(
        _fn(fn),
        headers: _headers(),
        body: jsonEncode(body),
      );
    } on EvidenceException {
      rethrow;
    } catch (_) {
      throw const EvidenceException('network_error');
    }
  }

  @override
  Future<List<EvidenceFile>> list(String caseId) async {
    final http.Response r = await _post('list-evidence', <String, dynamic>{
      'case_id': caseId,
    });
    if (r.statusCode != 200) throw EvidenceException(_code(r));
    final List<dynamic> items =
        (jsonDecode(r.body) as Map<String, dynamic>)['evidence']
            as List<dynamic>? ??
        <dynamic>[];
    return items
        .map((dynamic e) => EvidenceFile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EvidenceFile> upload({
    required String caseId,
    required EvidenceCategory category,
    required PickedEvidence file,
    String? title,
    String? description,
    String? documentDate,
  }) async {
    final String hash = crypto.sha256.convert(file.bytes).toString();

    // 1) Authorise the upload and get a signed URL.
    final http.Response r1 = await _post('create-upload', <String, dynamic>{
      'case_id': caseId,
      'mime_type': file.mimeType,
      'size_bytes': file.sizeBytes,
    });
    if (r1.statusCode != 200) throw EvidenceException(_code(r1));
    final Map<String, dynamic> up = jsonDecode(r1.body) as Map<String, dynamic>;
    final String storagePath = up['storage_path'] as String;
    final String signedUrl = up['signed_url'] as String;

    // 2) Upload the bytes directly to storage via the signed URL.
    try {
      final http.Response put = await http.put(
        Uri.parse(signedUrl),
        headers: <String, String>{
          'content-type': file.mimeType,
          'x-upsert': 'true',
        },
        body: file.bytes,
      );
      if (put.statusCode >= 300) throw const EvidenceException('upload_failed');
    } on EvidenceException {
      rethrow;
    } catch (_) {
      throw const EvidenceException('upload_failed');
    }

    // 3) Record the metadata now the object exists (FR-EVD-04).
    final http.Response r3 = await _post('complete-upload', <String, dynamic>{
      'case_id': caseId,
      'storage_path': storagePath,
      'category': category.code,
      'original_filename': file.name,
      'mime_type': file.mimeType,
      'size_bytes': file.sizeBytes,
      'sha256_hash': hash,
      'title': ?title,
      'description': ?description,
      'document_date': ?documentDate,
    });
    if (r3.statusCode != 200 && r3.statusCode != 201) {
      throw EvidenceException(_code(r3));
    }
    final String id =
        (jsonDecode(r3.body) as Map<String, dynamic>)['id'] as String;

    return EvidenceFile(
      id: id,
      category: category.code,
      originalFilename: file.name,
      mimeType: file.mimeType,
      sizeBytes: file.sizeBytes,
      uploadedAt: DateTime.now().toUtc().toIso8601String(),
      title: title,
      description: description,
      documentDate: documentDate,
      sha256Hash: hash,
    );
  }

  @override
  Future<EvidencePreview> preview(EvidenceFile evidence) async {
    final http.Response r = await _post('create-download', <String, dynamic>{
      'evidence_id': evidence.id,
      'download': false,
    });
    if (r.statusCode != 200) throw EvidenceException(_code(r));
    final Map<String, dynamic> j = jsonDecode(r.body) as Map<String, dynamic>;
    return EvidencePreview(
      url: j['url'] as String?,
      mimeType: (j['mime_type'] ?? evidence.mimeType).toString(),
    );
  }

  @override
  Future<String?> downloadUrl(EvidenceFile evidence) async {
    final http.Response r = await _post('create-download', <String, dynamic>{
      'evidence_id': evidence.id,
      'download': true,
    });
    if (r.statusCode != 200) throw EvidenceException(_code(r));
    return (jsonDecode(r.body) as Map<String, dynamic>)['url'] as String?;
  }

  @override
  Future<Uint8List?> fetchBytes(EvidenceFile evidence) async {
    final http.Response r = await _post('create-download', <String, dynamic>{
      'evidence_id': evidence.id,
      'download': false,
    });
    if (r.statusCode != 200) return null;
    final String? url =
        (jsonDecode(r.body) as Map<String, dynamic>)['url'] as String?;
    if (url == null) return null;
    try {
      final http.Response file = await http.get(Uri.parse(url));
      if (file.statusCode == 200) return file.bodyBytes;
    } catch (_) {
      // Unreachable object / CORS / network — treat as unavailable.
    }
    return null;
  }

  @override
  Future<void> delete(EvidenceFile evidence) async {
    final http.Response r = await _post('delete-evidence', <String, dynamic>{
      'evidence_id': evidence.id,
    });
    if (r.statusCode != 200) throw EvidenceException(_code(r));
  }

  String _code(http.Response r) {
    try {
      final Object? error =
          (jsonDecode(r.body) as Map<String, dynamic>)['error'];
      if (error is Map && error['code'] is String) {
        return error['code'] as String;
      }
    } catch (_) {
      // fall through
    }
    return 'request_failed';
  }
}

/// Demo repository: evidence metadata persists in `shared_preferences`; the file
/// bytes are kept only in memory for the session (enough to preview images
/// without a backend). MVP has one case, so a single list is used.
class LocalEvidenceRepository implements EvidenceRepository {
  LocalEvidenceRepository(this._prefs);

  final SharedPreferences _prefs;

  /// Public so account deletion can wipe demo data (see AuthController).
  static const String prefsKey = 'local_evidence';
  static final Map<String, Uint8List> _sessionBytes = <String, Uint8List>{};

  List<EvidenceFile> _read() {
    final String? raw = _prefs.getString(prefsKey);
    if (raw == null) return <EvidenceFile>[];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((dynamic e) => EvidenceFile.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <EvidenceFile>[];
    }
  }

  Future<void> _writeAll(List<EvidenceFile> items) async {
    await _prefs.setString(
      prefsKey,
      jsonEncode(items.map((EvidenceFile e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<EvidenceFile>> list(String caseId) async => _read();

  @override
  Future<EvidenceFile> upload({
    required String caseId,
    required EvidenceCategory category,
    required PickedEvidence file,
    String? title,
    String? description,
    String? documentDate,
  }) async {
    final String id = 'ev-${DateTime.now().microsecondsSinceEpoch}';
    final EvidenceFile evidence = EvidenceFile(
      id: id,
      category: category.code,
      originalFilename: file.name,
      mimeType: file.mimeType,
      sizeBytes: file.sizeBytes,
      uploadedAt: DateTime.now().toUtc().toIso8601String(),
      title: title,
      description: description,
      documentDate: documentDate,
      sha256Hash: crypto.sha256.convert(file.bytes).toString(),
    );
    _sessionBytes[id] = file.bytes;
    final List<EvidenceFile> items = _read()..insert(0, evidence);
    await _writeAll(items);
    return evidence;
  }

  @override
  Future<EvidencePreview> preview(EvidenceFile evidence) async {
    return EvidencePreview(
      bytes: _sessionBytes[evidence.id],
      mimeType: evidence.mimeType,
    );
  }

  @override
  Future<String?> downloadUrl(EvidenceFile evidence) async => null;

  @override
  Future<Uint8List?> fetchBytes(EvidenceFile evidence) async =>
      _sessionBytes[evidence.id];

  @override
  Future<void> delete(EvidenceFile evidence) async {
    _sessionBytes.remove(evidence.id);
    final List<EvidenceFile> items = _read()
        .where((EvidenceFile e) => e.id != evidence.id)
        .toList();
    await _writeAll(items);
  }
}

final Provider<EvidenceRepository> evidenceRepositoryProvider =
    Provider<EvidenceRepository>((Ref ref) {
      if (AppConfig.hasBackend) return RemoteEvidenceRepository(ref);
      return LocalEvidenceRepository(ref.read(sharedPreferencesProvider));
    });
