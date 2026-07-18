import 'package:flutter/widgets.dart';

// Web implementation is selected only when compiling for the web (JS or wasm —
// the implementation uses package:web/dart:js_interop, so `js_interop` is the
// correct condition; `dart.library.html` would be false under --wasm and
// silently disable real sign-in). VM widget tests and any non-web target use
// the no-op stub.
import 'gis_stub.dart' if (dart.library.js_interop) 'gis_web.dart' as impl;

/// Thin facade over the Google Identity Services (GIS) SDK.
///
/// The GIS-rendered button is the preferred implementation because it
/// automatically follows Google's current branding guideline (FR-AUTH-13). The
/// sign-in callback yields a Google **ID token** (a JWT) which the app sends to
/// the `create-or-update-user` Edge Function for verification.
class Gis {
  const Gis._();

  /// Whether real GIS is available on this platform (web only).
  static bool get isSupported => impl.gisIsSupported;

  /// Loads GIS (if needed) and initialises it with the OAuth [clientId].
  /// [onCredential] is invoked with the Google ID token on successful sign-in.
  static Future<void> initialize({
    required String clientId,
    required void Function(String idToken) onCredential,
  }) => impl.gisInitialize(clientId: clientId, onCredential: onCredential);

  /// The official GIS button rendered into a platform view.
  static Widget button({
    required bool isDark,
    String? locale,
    double width = 320,
  }) => impl.gisButton(isDark: isDark, locale: locale, width: width);

  /// Clears GIS auto-select so the next visit is not auto-signed-in
  /// (FR-AUTH-11).
  static void signOut() => impl.gisSignOut();
}
