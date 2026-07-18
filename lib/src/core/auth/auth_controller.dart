import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sewabukti/src/core/auth/auth_repository.dart';
import 'package:sewabukti/src/core/auth/google/gis.dart';
import 'package:sewabukti/src/core/auth/user_profile.dart';
import 'package:sewabukti/src/core/config/app_config.dart';
import 'package:sewabukti/src/core/preferences/app_language.dart';
import 'package:sewabukti/src/core/preferences/preferences_providers.dart';
import 'package:sewabukti/src/features/cases/case_repository.dart';
import 'package:sewabukti/src/features/evidence/evidence_repository.dart';

enum AuthStatus { signedOut, authenticating, signedIn }

/// Authentication state. Holds the internal SewaBukti user id (mapped from the
/// verified Google `sub` server-side, FR-AUTH-08/09) and the current Google ID
/// token, kept in memory only for authenticated backend calls — never persisted
/// to storage or logs (FR-AUTH-12).
class AuthState {
  const AuthState({
    this.status = AuthStatus.signedOut,
    this.userId,
    this.displayName,
    this.email,
    this.idToken,
    this.errorCode,
  });

  final AuthStatus status;
  final String? userId;
  final String? displayName;
  final String? email;
  final String? idToken;
  final String? errorCode;

  bool get isSignedIn => status == AuthStatus.signedIn;
  bool get isAuthenticating => status == AuthStatus.authenticating;
}

/// Auth controller. Real sign-in uses direct Google Identity Services: the
/// client obtains a Google ID token and the `create-or-update-user` Edge
/// Function verifies it (signature/issuer/audience/expiry/verified-email) and
/// returns the internal profile (FR-AUTH-01..09). Supabase Auth is not used
/// (NFR-SEC-23).
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  /// Completes sign-in from a Google ID token produced by GIS. Sends the token
  /// to the backend for verification, then applies the returned profile's
  /// language/theme preferences (FR-PREF-06/11).
  Future<void> signInWithIdToken(String idToken) async {
    state = const AuthState(status: AuthStatus.authenticating);

    final AuthRepository repo = ref.read(authRepositoryProvider);
    final LocaleController localeNotifier = ref.read(
      localeControllerProvider.notifier,
    );
    final ThemeModeController themeNotifier = ref.read(
      themeModeControllerProvider.notifier,
    );

    final String currentLanguage = localeNotifier.current.code;
    final String currentTheme =
        ref.read(themeModeControllerProvider) == ThemeMode.dark
        ? 'dark'
        : 'light';

    try {
      final UserProfile profile = await repo.createOrUpdateUser(
        idToken: idToken,
        preferredLanguage: currentLanguage,
        themeMode: currentTheme,
      );

      // Apply the profile's preferences returned by the server.
      await localeNotifier.setLanguage(
        AppLanguage.fromCode(profile.preferredLanguage),
      );
      await themeNotifier.setDark(profile.themeMode == 'dark');

      state = AuthState(
        status: AuthStatus.signedIn,
        userId: profile.id,
        displayName: profile.fullName,
        email: profile.email,
        idToken: idToken,
      );
    } on AuthException catch (error) {
      state = AuthState(status: AuthStatus.signedOut, errorCode: error.code);
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.signedOut,
        errorCode: 'sign_in_failed',
      );
    }
  }

  /// Local demo sign-in used only when GIS/backend are not configured (dev and
  /// widget tests), so the authenticated shell can be navigated.
  void signInWithPlaceholder() {
    state = const AuthState(
      status: AuthStatus.signedIn,
      userId: 'demo-user',
      displayName: 'Demo Tenant',
      email: 'demo.tenant@example.com',
    );
  }

  /// Best-effort sync of a preference change to the profile while signed in
  /// (FR-PREF-06/11). Requires a still-valid ID token; silently no-ops
  /// otherwise (the local preference has already been applied).
  Future<void> syncPreferences({String? language, String? themeMode}) async {
    final String? token = state.idToken;
    if (!state.isSignedIn || token == null) return;
    try {
      await ref
          .read(authRepositoryProvider)
          .createOrUpdateUser(
            idToken: token,
            preferredLanguage: language,
            themeMode: themeMode,
          );
    } catch (_) {
      // Non-fatal: local preference remains applied.
    }
  }

  /// Signs the user out. [reason] optionally records why (e.g.
  /// `inactive_timeout`) so the landing page can explain it; a normal
  /// user-initiated sign-out passes none.
  void signOut({String? reason}) {
    Gis.signOut(); // clear GIS auto-select (FR-AUTH-11); no-op if unsupported
    state = AuthState(errorCode: reason);
  }

  /// Permanently deletes the account and application data (NFR-SEC-12/15), then
  /// signs out. With a backend, the server removes storage objects and records;
  /// in the demo build it clears the locally persisted case/evidence. Throws
  /// [AuthException] if the backend deletion fails (so the UI can report it).
  Future<void> deleteAccount() async {
    final String? token = state.idToken;
    if (AppConfig.hasBackend && token != null) {
      await ref.read(authRepositoryProvider).deleteAccount(idToken: token);
    }
    // Clear any locally persisted demo data so nothing lingers after deletion.
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(LocalCaseRepository.prefsKey);
    await prefs.remove(LocalEvidenceRepository.prefsKey);
    signOut();
  }
}

final NotifierProvider<AuthController, AuthState> authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
