import 'dart:async';

/// Reason code recorded on [AuthController.signOut] when a session ends from
/// inactivity, so the landing page can explain why (see `InactivityGuard`).
const String kInactiveTimeoutReason = 'inactive_timeout';

/// Signs a user out after a period with no interaction (§ session hygiene).
///
/// A single resettable one-shot timer counts down [timeout]; [recordActivity]
/// restarts it, and [onTimeout] fires once if the countdown ever completes.
/// The timeout comes from `AppConfig.inactiveTimeoutSeconds` (a repo variable,
/// seconds); a non-positive value disables the service entirely.
///
/// This is a client-side convenience/hygiene control, not a server-enforced
/// session limit — the ID token's own expiry remains the security boundary.
class InactivityService {
  InactivityService({required this.timeout, required this.onTimeout});

  final Duration timeout;
  final void Function() onTimeout;

  Timer? _timer;

  /// Whether a positive timeout is configured. When false, every method no-ops.
  bool get isEnabled => timeout > Duration.zero;

  /// Whether the countdown is currently running.
  bool get isArmed => _timer != null;

  /// Begins the countdown. Call when the user becomes authenticated. Safe to
  /// call repeatedly — it simply restarts the countdown.
  void start() {
    if (!isEnabled) return;
    _arm();
  }

  /// Restarts the countdown because the user interacted. No-op unless the
  /// countdown is already running, so activity before [start] (or after the
  /// timeout has already fired) is ignored.
  void recordActivity() {
    if (_timer == null) return;
    _arm();
  }

  /// Cancels the countdown. Call on sign-out and on dispose.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _arm() {
    _timer?.cancel();
    _timer = Timer(timeout, () {
      _timer = null;
      onTimeout();
    });
  }
}
