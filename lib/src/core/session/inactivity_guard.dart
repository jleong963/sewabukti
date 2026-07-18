import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sewabukti/src/core/auth/auth_controller.dart';
import 'package:sewabukti/src/core/config/app_config.dart';
import 'package:sewabukti/src/core/session/inactivity_service.dart';

/// Wraps the app and auto-signs-out an idle user after
/// [AppConfig.inactiveTimeoutSeconds] (0 disables — then this is a transparent
/// pass-through). Pointer events (tap, drag, hover, scroll) and key presses
/// anywhere in the app count as activity and restart the countdown; the
/// countdown only runs while signed in.
class InactivityGuard extends ConsumerStatefulWidget {
  const InactivityGuard({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<InactivityGuard> createState() => _InactivityGuardState();
}

class _InactivityGuardState extends ConsumerState<InactivityGuard> {
  late final bool _enabled = AppConfig.inactiveTimeoutSeconds > 0;
  late final InactivityService _service = InactivityService(
    timeout: Duration(seconds: AppConfig.inactiveTimeoutSeconds),
    onTimeout: _handleTimeout,
  );

  // Activity fires very frequently (e.g. pointer hover); coalesce it so the
  // countdown is restarted at most once per second.
  static const Duration _throttle = Duration(seconds: 1);
  DateTime? _lastRecorded;

  @override
  void initState() {
    super.initState();
    if (!_enabled) return;
    HardwareKeyboard.instance.addHandler(_onKey);
    // The app always launches signed out; the auth listener in build() arms the
    // countdown on sign-in. Guard the startup case anyway.
    if (ref.read(authControllerProvider).isSignedIn) _service.start();
  }

  @override
  void dispose() {
    if (_enabled) HardwareKeyboard.instance.removeHandler(_onKey);
    _service.stop();
    super.dispose();
  }

  void _handleTimeout() {
    if (!ref.read(authControllerProvider).isSignedIn) return;
    ref
        .read(authControllerProvider.notifier)
        .signOut(reason: kInactiveTimeoutReason);
  }

  // Observe key presses app-wide without consuming them.
  bool _onKey(KeyEvent event) {
    _recordActivity();
    return false;
  }

  void _recordActivity() {
    if (!_service.isArmed) return; // only while the countdown is running
    final DateTime now = DateTime.now();
    if (_lastRecorded != null && now.difference(_lastRecorded!) < _throttle) {
      return;
    }
    _lastRecorded = now;
    _service.recordActivity();
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return widget.child;

    ref.listen<AuthState>(authControllerProvider, (
      AuthState? previous,
      AuthState next,
    ) {
      final bool wasSignedIn = previous?.isSignedIn ?? false;
      if (next.isSignedIn && !wasSignedIn) {
        _service.start();
      } else if (!next.isSignedIn && wasSignedIn) {
        _service.stop();
      }
    });

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _recordActivity(),
      onPointerMove: (_) => _recordActivity(),
      onPointerHover: (_) => _recordActivity(),
      onPointerSignal: (_) => _recordActivity(),
      child: widget.child,
    );
  }
}
