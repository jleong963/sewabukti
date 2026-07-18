import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sewabukti/src/core/auth/auth_controller.dart';
import 'package:sewabukti/src/core/config/app_config.dart';
import 'package:sewabukti/src/core/preferences/preferences_providers.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';

class CaseException implements Exception {
  const CaseException(this.code);
  final String code;
  @override
  String toString() => 'CaseException($code)';
}

abstract interface class CaseRepository {
  Future<Case?> getCurrentCase();
  Future<Case> createCase();
  Future<Case> updateCase(String id, Map<String, dynamic> changes);
  Future<void> deleteCase(String id);
}

/// Talks to the Supabase Edge Functions, authenticated with the Google ID token
/// held in auth state (FR-AUTH-03). Ownership is enforced server-side.
class RemoteCaseRepository implements CaseRepository {
  RemoteCaseRepository(this._ref);

  final Ref _ref;

  Uri _fn(String name) =>
      Uri.parse('${AppConfig.supabaseUrl}/functions/v1/$name');

  Map<String, String> _headers() {
    final String? token = _ref.read(authControllerProvider).idToken;
    if (token == null) throw const CaseException('not_authenticated');
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
    } on CaseException {
      rethrow;
    } catch (_) {
      throw const CaseException('network_error');
    }
  }

  @override
  Future<Case?> getCurrentCase() async {
    final http.Response r = await _post('get-case', <String, dynamic>{});
    if (r.statusCode == 404) return null;
    if (r.statusCode != 200) throw CaseException(_errorCode(r));
    return Case.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  @override
  Future<Case> createCase() async {
    final http.Response r = await _post('create-case', <String, dynamic>{});
    if (r.statusCode != 200 && r.statusCode != 201) {
      throw CaseException(_errorCode(r));
    }
    return Case.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  @override
  Future<Case> updateCase(String id, Map<String, dynamic> changes) async {
    final http.Response r = await _post('update-case', <String, dynamic>{
      'case_id': id,
      ...changes,
    });
    if (r.statusCode != 200) throw CaseException(_errorCode(r));
    return Case.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCase(String id) async {
    final http.Response r = await _post('delete-case', <String, dynamic>{
      'case_id': id,
    });
    if (r.statusCode != 200) throw CaseException(_errorCode(r));
  }

  String _errorCode(http.Response r) {
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

/// Persists a single case to `shared_preferences` so the wizard's save/resume
/// works in the demo/dev build without a deployed backend.
class LocalCaseRepository implements CaseRepository {
  LocalCaseRepository(this._prefs);

  final SharedPreferences _prefs;

  /// Public so account deletion can wipe demo data (see AuthController).
  static const String prefsKey = 'local_case';

  Case? _read() {
    final String? raw = _prefs.getString(prefsKey);
    if (raw == null) return null;
    try {
      return Case.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<Case> _write(Case c) async {
    final Map<String, dynamic> json = c.toJson();
    // Never persist the identity number to browser storage in the demo build.
    // The real path encrypts it at rest server-side; here it is kept in memory
    // only for the current session.
    json['claimant_id_number'] = null;
    await _prefs.setString(prefsKey, jsonEncode(json));
    return c;
  }

  @override
  Future<Case?> getCurrentCase() async => _read();

  @override
  Future<Case> createCase() async {
    final Case? existing = _read();
    if (existing != null) return existing; // one case per user (§12.2)
    return _write(
      Case.newLocal('local-${DateTime.now().microsecondsSinceEpoch}'),
    );
  }

  @override
  Future<Case> updateCase(String id, Map<String, dynamic> changes) async {
    final Case current = _read() ?? Case.newLocal(id);
    return _write(current.mergedWith(changes));
  }

  @override
  Future<void> deleteCase(String id) async {
    await _prefs.remove(prefsKey);
  }
}

final Provider<CaseRepository> caseRepositoryProvider =
    Provider<CaseRepository>((Ref ref) {
      if (AppConfig.hasBackend) return RemoteCaseRepository(ref);
      return LocalCaseRepository(ref.read(sharedPreferencesProvider));
    });
