// create-or-update-user
//
// Called by the Flutter client immediately after a successful Google sign-in.
// Verifies the Google ID token (fail-closed), maps the Google `sub` to an
// internal user, creates the record on first sign-in (FR-AUTH-02), optionally
// syncs the user's language/theme preference, and returns the profile.
//
// Order matters: token verification runs before any application logic (§14).
import { handlePreflight } from "../_shared/cors.ts";
import { errorResponse, jsonResponse } from "../_shared/http.ts";
import {
  AuthError,
  bearerToken,
  verifyGoogleIdToken,
} from "../_shared/google_auth.ts";
import { type PreferenceInput, resolveOrCreateUser } from "../_shared/users.ts";
import { writeAudit } from "../_shared/audit.ts";

Deno.serve(async (req: Request): Promise<Response> => {
  const preflight = handlePreflight(req);
  if (preflight) return preflight;

  if (req.method !== "POST") {
    return errorResponse(405, "method_not_allowed", "Use POST");
  }

  try {
    // 1) Verify identity first — fail closed before touching the database.
    const identity = await verifyGoogleIdToken(bearerToken(req));

    // 2) Read optional, validated preference sync from the body.
    const prefs: PreferenceInput = {};
    try {
      const body = await req.json();
      if (body && typeof body === "object") {
        const b = body as Record<string, unknown>;
        if (typeof b.preferred_language === "string") {
          prefs.preferredLanguage = b.preferred_language;
        }
        if (typeof b.theme_mode === "string") {
          prefs.themeMode = b.theme_mode;
        }
      }
    } catch (_error) {
      // No/invalid body is acceptable for this endpoint.
    }

    // 3) Resolve identity -> internal user (create on first sign-in).
    const profile = await resolveOrCreateUser(identity, prefs);

    await writeAudit({
      userId: profile.id,
      action: "user.sign_in",
      entityType: "user",
      entityId: profile.id,
    });

    return jsonResponse({
      id: profile.id,
      email: profile.email,
      full_name: profile.fullName,
      preferred_language: profile.preferredLanguage,
      theme_mode: profile.themeMode,
    });
  } catch (error) {
    if (error instanceof AuthError) {
      const status = error.code === "server_misconfigured" ? 500 : 401;
      return errorResponse(status, error.code, error.message);
    }
    // Never surface internal error details or stack traces (§14.10).
    return errorResponse(500, "internal_error", "Unexpected error");
  }
});
