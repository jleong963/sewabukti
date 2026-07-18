import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:sewabukti/src/core/config/app_config.dart';
import 'package:sewabukti/src/core/auth/user_profile.dart';

/// Thrown when a backend auth call fails. [code] is a stable, non-sensitive
/// error code (never a stack trace or internal detail).
class AuthException implements Exception {
  const AuthException(this.code, [this.message]);

  final String code;
  final String? message;

  @override
  String toString() => 'AuthException($code)';
}

/// Talks to the Supabase Edge Functions using the Google ID token as a bearer
/// (FR-AUTH-03). The client never holds server-side secrets; it sends the
/// public anon key as `apikey` for gateway routing (§7.3).
class AuthRepository {
  const AuthRepository();

  Uri _functionUri(String name) =>
      Uri.parse('${AppConfig.supabaseUrl}/functions/v1/$name');

  /// Verifies the token server-side, creates/updates the user, and returns the
  /// profile. Optionally syncs the language/theme preference (FR-PREF-06/11).
  Future<UserProfile> createOrUpdateUser({
    required String idToken,
    String? preferredLanguage,
    String? themeMode,
  }) async {
    if (AppConfig.supabaseUrl.isEmpty) {
      throw const AuthException('backend_unconfigured');
    }

    final http.Response response;
    try {
      response = await http.post(
        _functionUri('create-or-update-user'),
        headers: <String, String>{
          'Authorization': 'Bearer $idToken',
          'apikey': AppConfig.supabaseAnonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'preferred_language': ?preferredLanguage,
          'theme_mode': ?themeMode,
        }),
      );
    } catch (_) {
      throw const AuthException('network_error');
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      return UserProfile.fromJson(body);
    }

    // Surface the server's stable error code without leaking internals.
    String code = 'sign_in_failed';
    try {
      final Object? error =
          (jsonDecode(response.body) as Map<String, dynamic>)['error'];
      if (error is Map && error['code'] is String) {
        code = error['code'] as String;
      }
    } catch (_) {
      // Non-JSON error body; keep the generic code.
    }
    throw AuthException(code, 'HTTP ${response.statusCode}');
  }

  /// Permanently deletes the account, its storage objects, and Turso records
  /// (NFR-SEC-12/15). Server-verified by the Google ID token.
  Future<void> deleteAccount({required String idToken}) async {
    if (AppConfig.supabaseUrl.isEmpty) {
      throw const AuthException('backend_unconfigured');
    }
    final http.Response response;
    try {
      response = await http.post(
        _functionUri('delete-account'),
        headers: <String, String>{
          'Authorization': 'Bearer $idToken',
          'apikey': AppConfig.supabaseAnonKey,
          'Content-Type': 'application/json',
        },
        body: '{}',
      );
    } catch (_) {
      throw const AuthException('network_error');
    }
    if (response.statusCode != 200) {
      String code = 'delete_failed';
      try {
        final Object? error =
            (jsonDecode(response.body) as Map<String, dynamic>)['error'];
        if (error is Map && error['code'] is String) {
          code = error['code'] as String;
        }
      } catch (_) {
        // keep generic code
      }
      throw AuthException(code, 'HTTP ${response.statusCode}');
    }
  }
}

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref ref) => const AuthRepository());
