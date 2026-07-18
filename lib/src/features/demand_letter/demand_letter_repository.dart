import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:sewabukti/src/core/auth/auth_controller.dart';
import 'package:sewabukti/src/core/config/app_config.dart';

class DemandLetterException implements Exception {
  const DemandLetterException(this.code);
  final String code;
  @override
  String toString() => 'DemandLetterException($code)';
}

class DemandLetterResult {
  const DemandLetterResult({required this.deliveryStatus, this.version});
  final String deliveryStatus;
  final int? version;
}

abstract interface class DemandLetterRepository {
  Future<DemandLetterResult> send({
    required String caseId,
    required String language,
    required String recipientEmail,
    required String subject,
    required String html,
    String? pdfBase64,
  });
}

/// Sends via the server-side `send-demand-letter` function (Gmail SMTP is
/// invoked only there, FR-DL-05). A failed send is surfaced, never faked
/// (FR-DL-06).
class RemoteDemandLetterRepository implements DemandLetterRepository {
  RemoteDemandLetterRepository(this._ref);

  final Ref _ref;

  @override
  Future<DemandLetterResult> send({
    required String caseId,
    required String language,
    required String recipientEmail,
    required String subject,
    required String html,
    String? pdfBase64,
  }) async {
    final String? token = _ref.read(authControllerProvider).idToken;
    if (token == null) throw const DemandLetterException('not_authenticated');

    final http.Response r;
    try {
      r = await http.post(
        Uri.parse('${AppConfig.supabaseUrl}/functions/v1/send-demand-letter'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'apikey': AppConfig.supabaseAnonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'case_id': caseId,
          'language': language,
          'recipient_email': recipientEmail,
          'subject': subject,
          'letter_html': html,
          'pdf_base64': ?pdfBase64,
        }),
      );
    } catch (_) {
      throw const DemandLetterException('network_error');
    }

    if (r.statusCode != 200) {
      String code = 'send_failed';
      try {
        final Object? error =
            (jsonDecode(r.body) as Map<String, dynamic>)['error'];
        if (error is Map && error['code'] is String) {
          code = error['code'] as String;
        }
      } catch (_) {
        // keep generic code
      }
      throw DemandLetterException(code);
    }

    final Map<String, dynamic> body =
        jsonDecode(r.body) as Map<String, dynamic>;
    return DemandLetterResult(
      deliveryStatus: (body['delivery_status'] ?? 'sent').toString(),
      version: (body['version'] as num?)?.toInt(),
    );
  }
}

/// Demo: email cannot be sent without a backend; the PDF download still works.
class LocalDemandLetterRepository implements DemandLetterRepository {
  const LocalDemandLetterRepository();

  @override
  Future<DemandLetterResult> send({
    required String caseId,
    required String language,
    required String recipientEmail,
    required String subject,
    required String html,
    String? pdfBase64,
  }) async {
    throw const DemandLetterException('backend_required');
  }
}

final Provider<DemandLetterRepository> demandLetterRepositoryProvider =
    Provider<DemandLetterRepository>((Ref ref) {
      if (AppConfig.hasBackend) return RemoteDemandLetterRepository(ref);
      return const LocalDemandLetterRepository();
    });
