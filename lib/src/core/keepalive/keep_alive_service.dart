import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:sewabukti/src/core/config/app_config.dart';

/// Periodically pings the `keep-alive` Edge Function while the app is open so
/// the free-tier Supabase project does not pause from inactivity. The interval
/// comes from [AppConfig.keepAliveIntervalSeconds] (a repo variable, seconds);
/// 0 or a missing backend disables it.
///
/// This only covers periods when someone has the app open. Zero-user periods
/// are covered by the scheduled `keep-alive` GitHub Actions workflow.
class KeepAliveService {
  KeepAliveService();

  Timer? _timer;

  bool get isEnabled =>
      AppConfig.hasBackend && AppConfig.keepAliveIntervalSeconds > 0;

  void start() {
    if (!isEnabled || _timer != null) return;
    final Duration interval = Duration(
      seconds: AppConfig.keepAliveIntervalSeconds,
    );
    _timer = Timer.periodic(interval, (_) => _ping());
    _ping(); // touch immediately on start
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _ping() async {
    try {
      await http.get(
        Uri.parse('${AppConfig.supabaseUrl}/functions/v1/keep-alive'),
        headers: <String, String>{'apikey': AppConfig.supabaseAnonKey},
      );
    } catch (_) {
      // A failed ping is non-fatal; the next tick retries.
    }
  }
}

final Provider<KeepAliveService> keepAliveServiceProvider =
    Provider<KeepAliveService>((Ref ref) {
      final KeepAliveService service = KeepAliveService();
      ref.onDispose(service.stop);
      return service;
    });
