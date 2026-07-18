// User resolution: map the verified Google `sub` to an internal SewaBukti UUID
// (FR-AUTH-09), creating the record on first sign-in (FR-AUTH-02). All queries
// are parameterised (§14.8). A client-supplied user id is never trusted
// (FR-AUTH-05) — identity comes only from the verified token.
import { turso } from "./turso.ts";
import { AuthError, type GoogleIdentity } from "./google_auth.ts";

export interface UserProfile {
  id: string;
  email: string;
  fullName: string | null;
  preferredLanguage: string;
  themeMode: string;
}

const LANGUAGES = new Set(["en", "ms", "zh-Hans"]);
const THEMES = new Set(["light", "dark"]);

export interface PreferenceInput {
  preferredLanguage?: string;
  themeMode?: string;
}

/**
 * Enforces the beta user cap (§12 free-tier protection) before a NEW user
 * record is created. `MAX_BETA_USERS` unset or <= 0 disables the cap. The
 * client shows a localised "beta is full" message for the `beta_full` code
 * (see landing_page.dart); existing users always keep signing in.
 */
async function assertBetaCapacity(): Promise<void> {
  const cap = Number(Deno.env.get("MAX_BETA_USERS") ?? "0");
  if (!Number.isFinite(cap) || cap <= 0) return;
  const result = await turso().execute(
    "SELECT COUNT(*) AS n FROM users WHERE deleted_at IS NULL",
  );
  const count = Number(
    (result.rows[0] as unknown as Record<string, unknown>).n ?? 0,
  );
  if (count >= cap) {
    throw new AuthError("beta_full", "Beta capacity reached");
  }
}

/**
 * Re-reads a user id after an INSERT lost a `google_subject_id` UNIQUE race
 * (two concurrent first sign-ins). Returns null when the failure was not that
 * race, in which case the original error should propagate.
 */
async function findExistingId(sub: string): Promise<string | null> {
  const found = await turso().execute({
    sql:
      "SELECT id FROM users WHERE google_subject_id = ? AND deleted_at IS NULL",
    args: [sub],
  });
  if (found.rows.length === 0) return null;
  return String((found.rows[0] as unknown as Record<string, unknown>).id);
}

/** Returns the profile for the identity, creating or updating it as needed. */
export async function resolveOrCreateUser(
  identity: GoogleIdentity,
  prefs: PreferenceInput,
): Promise<UserProfile> {
  const db = turso();
  const now = new Date().toISOString();

  const language = prefs.preferredLanguage && LANGUAGES.has(prefs.preferredLanguage)
    ? prefs.preferredLanguage
    : undefined;
  const theme = prefs.themeMode && THEMES.has(prefs.themeMode)
    ? prefs.themeMode
    : undefined;

  const existing = await db.execute({
    sql:
      `SELECT id, email, full_name, preferred_language, theme_mode
         FROM users
        WHERE google_subject_id = ? AND deleted_at IS NULL`,
    args: [identity.sub],
  });

  if (existing.rows.length === 0) {
    await assertBetaCapacity();
    const id = crypto.randomUUID();
    try {
      await db.execute({
        sql:
          `INSERT INTO users
             (id, google_subject_id, email, full_name,
              preferred_language, theme_mode, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        args: [
          id,
          identity.sub,
          identity.email,
          identity.name ?? null,
          language ?? "en",
          theme ?? "light",
          now,
          now,
        ],
      });
    } catch (error) {
      // A concurrent first sign-in won the UNIQUE(google_subject_id) race;
      // retry once so this request takes the normal update path.
      if (await findExistingId(identity.sub) == null) throw error;
      return resolveOrCreateUser(identity, prefs);
    }
    return {
      id,
      email: identity.email,
      fullName: identity.name ?? null,
      preferredLanguage: language ?? "en",
      themeMode: theme ?? "light",
    };
  }

  const row = existing.rows[0] as unknown as Record<string, unknown>;
  const id = String(row.id);
  const currentName = row.full_name == null ? null : String(row.full_name);

  // Google is the source of truth for email/name; only apply valid prefs.
  await db.execute({
    sql:
      `UPDATE users
          SET email = ?,
              full_name = ?,
              preferred_language = COALESCE(?, preferred_language),
              theme_mode = COALESCE(?, theme_mode),
              updated_at = ?
        WHERE id = ?`,
    args: [
      identity.email,
      identity.name ?? currentName,
      language ?? null,
      theme ?? null,
      now,
      id,
    ],
  });

  return {
    id,
    email: identity.email,
    fullName: identity.name ?? currentName,
    preferredLanguage: language ?? String(row.preferred_language),
    themeMode: theme ?? String(row.theme_mode),
  };
}

/**
 * Soft-deletes the account (§23.3 retention grace, NFR-SEC-12/15): the user is
 * marked `deleted_at` and their data disappears immediately (all reads filter
 * `deleted_at IS NULL`). Rows and storage objects are kept until the scheduled
 * purge removes them after the retention window. The `google_subject_id` is
 * tombstoned so that if the same Google account signs in again during the
 * window it starts fresh instead of colliding with the unique subject index.
 */
export async function softDeleteAccount(userId: string): Promise<void> {
  const now = new Date().toISOString();
  await turso().execute({
    sql: `UPDATE users
             SET deleted_at = ?,
                 google_subject_id = 'deleted:' || id,
                 updated_at = ?
           WHERE id = ? AND deleted_at IS NULL`,
    args: [now, now, userId],
  });
}

/**
 * Resolves the internal user id for a verified identity, creating a minimal
 * record if this is the first protected call before create-or-update-user ran.
 * Read-only for existing users (no write on every request).
 */
export async function resolveUserId(identity: GoogleIdentity): Promise<string> {
  const db = turso();
  const found = await db.execute({
    sql:
      "SELECT id FROM users WHERE google_subject_id = ? AND deleted_at IS NULL",
    args: [identity.sub],
  });
  if (found.rows.length > 0) {
    return String((found.rows[0] as unknown as Record<string, unknown>).id);
  }
  // Creating here (not just in create-or-update-user) keeps every protected
  // endpoint consistent, so the beta cap must be enforced on this path too.
  await assertBetaCapacity();
  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  try {
    await db.execute({
      sql:
        `INSERT INTO users
           (id, google_subject_id, email, full_name,
            preferred_language, theme_mode, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      args: [id, identity.sub, identity.email, identity.name ?? null, "en", "light", now, now],
    });
  } catch (error) {
    // Concurrent creation lost the UNIQUE(google_subject_id) race.
    const existingId = await findExistingId(identity.sub);
    if (existingId == null) throw error;
    return existingId;
  }
  return id;
}
