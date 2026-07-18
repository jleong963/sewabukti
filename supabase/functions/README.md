# SewaBukti Edge Functions (Supabase / Deno)

Server-side functions — the **only** place with privileged credentials (Turso
token, Gmail app password, Supabase service role); never the Flutter client
(§8.1).
Each protected function verifies the caller's **Google ID token** before any
logic and fails closed (§14, NFR-SEC-24/25). Supabase Auth is not used.

## Layout

```
_shared/
  cors.ts          CORS + preflight
  http.ts          JSON responses (no stack traces leaked)
  google_auth.ts   Google ID-token verification (jose + Google JWKS)
  handler.ts       withAuth(): verify token + resolve internal user, then run
  validation.ts    body parsing / field validation
  turso.ts         libSQL client (HTTP/web build)
  users.ts         sub -> internal UUID; create on first sign-in
  cases.ts         case CRUD, ownership, claim recalculation
  evidence.ts      evidence metadata + quota enforcement
  storage.ts       private bucket signed URLs (service role)
  email.ts         transactional email (Gmail SMTP) + daily limits
  audit.ts         non-sensitive audit events
  retention.ts     permanent purge of soft-deleted data (§23.3)

create-or-update-user/   post sign-in (create/update user, sync prefs)
create-case/  get-case/  update-case/  delete-case/
create-upload/  complete-upload/  delete-evidence/
send-demand-letter/  delete-account/
keep-alive/              unauthenticated liveness ping (anti-pause)
purge-deleted/           scheduled retention purge (shared secret, not a token)
```

All protected functions share `withAuth`, so the security order (verify →
resolve user → ownership) is uniform. `keep-alive` is intentionally
unauthenticated and does only a trivial `SELECT 1`. `purge-deleted` is a
scheduled system job guarded by the `PURGE_SECRET` shared secret (not a Google
token).

## Required secrets / env

`SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` are
auto-injected into Edge Functions by Supabase. Set the rest with
`supabase secrets set`:

| Name | Purpose |
|---|---|
| `GOOGLE_OAUTH_CLIENT_ID` | Expected ID-token audience (FR-AUTH-07) |
| `TURSO_DATABASE_URL` | libSQL endpoint (no token) |
| `TURSO_AUTH_TOKEN` | Turso access token |
| `GMAIL_USER` | Gmail address that sends demand-letter email (also the From mailbox) |
| `GMAIL_APP_PASSWORD` | 16-character Google **App Password** for `GMAIL_USER` (needs 2-Step Verification; not the account password) |
| `GMAIL_FROM` | Optional sender header. Defaults to `SewaBukti <GMAIL_USER>`; set it only to change the display name (the address stays the authenticated mailbox). Gmail delivers to arbitrary recipients with no domain to verify |
| `APP_ORIGIN` | Allowed CORS origin — the deployed app origin, e.g. `https://sewabukti.vercel.app` (scheme + host, **no trailing slash**); defaults to `*` |
| `APP_ENCRYPTION_KEY` | base64 of 32 random bytes; AES-GCM key encrypting the identity number at rest (see "Key rotation" for the multi-key alternative) |
| `PURGE_SECRET` | shared secret for the scheduled `purge-deleted` job (also a GitHub Actions secret) |
| `RETENTION_PURGE_DAYS` | optional; days a soft-deleted record is kept before purge (default 30, §23.3) |
| `MAX_BETA_USERS` | optional; beta user cap (§12 free-tier protection). When the count of non-deleted users reaches the cap, NEW sign-ups are refused with the `beta_full` code (shown localised on the sign-in page); existing users are unaffected. Unset or `0` disables the cap |

```bash
# Generate the encryption key once (keep it secret, never commit it):
openssl rand -base64 32

supabase secrets set GOOGLE_OAUTH_CLIENT_ID=... TURSO_DATABASE_URL=... \
  TURSO_AUTH_TOKEN=... GMAIL_USER=you@gmail.com GMAIL_APP_PASSWORD="xxxx xxxx xxxx xxxx" \
  APP_ORIGIN=https://sewabukti.vercel.app APP_ENCRYPTION_KEY=<base64-32-bytes>
```

## Sensitive data

The claimant identity number is **encrypted at rest** (AES-GCM, `crypto.ts`):
it is stored as opaque ciphertext in Turso and decrypted only server-side when
returned to its authenticated owner. If an identity number is submitted while
no key is configured, the request fails closed. Audit events never store field
values, and the Flutter demo build does not persist the identity number to
browser storage.

Ciphertext is tagged with the id of the key that wrote it
(`v1.<keyId>.<iv>.<ciphertext>`), which makes key rotation a configuration
change rather than a data migration.

### Key rotation (ready for future use — not yet operated)

Keys can be provided two ways:

- **Single key** (current): `APP_ENCRYPTION_KEY=<base64-32-bytes>` (used as id `1`).
- **Multiple keys** (for rotation): `APP_ENCRYPTION_KEYS="1:<base64>,2:<base64>"`
  plus `APP_ENCRYPTION_KEY_ACTIVE_ID=2` to choose which key encrypts new data.

To rotate in the future:

1. Generate a new key: `openssl rand -base64 32`.
2. Add it alongside the old one and make it active — **keep the old key** so
   existing rows still decrypt:
   ```bash
   supabase secrets set \
     APP_ENCRYPTION_KEYS="1:<old-base64>,2:<new-base64>" \
     APP_ENCRYPTION_KEY_ACTIVE_ID=2
   ```
   New writes are now tagged `v1.2.…`; old `v1.1.…` values keep decrypting.
3. (Optional, later) Re-encrypt existing rows with `reencryptSensitive` in a
   maintenance pass, then drop the retired key from `APP_ENCRYPTION_KEYS`.

## Data retention and deletion (§23.3, NFR-SEC-12/15)

Deleting a case or account is a **soft delete**: the row is marked `deleted_at`
and disappears from every read immediately (all case/user queries filter
`deleted_at IS NULL`; a deleted account's Google subject is tombstoned so a
later sign-in starts fresh instead of colliding). Rows and storage objects are
kept for a grace window so accidental deletion can be recovered, then removed
permanently.

`purge-deleted` performs the permanent removal — storage objects first, then the
DB rows (children cascade via foreign keys) — for anything soft-deleted more
than `RETENTION_PURGE_DAYS` ago (default 30). It is invoked daily by the
`.github/workflows/purge-deleted.yml` workflow, which POSTs with the
`x-purge-secret: <PURGE_SECRET>` header. Set the secret in both places:

```bash
purge_secret=$(openssl rand -base64 32)
supabase secrets set PURGE_SECRET="$purge_secret"   # server side
gh secret set PURGE_SECRET --body "$purge_secret"   # GitHub Actions
# optional: change the window
supabase secrets set RETENTION_PURGE_DAYS=30
```

## Run locally / deploy

Requires the Supabase CLI (bundles Deno). These functions were **not
type-checked in the build environment** (no Deno/CLI installed there) — validate
with the CLI before deploying:

```bash
supabase functions serve --no-verify-jwt --env-file supabase/.env.local
supabase functions deploy   # deploys all functions
```

`verify_jwt = false` is set for every function in `supabase/config.toml` because
the bearer is a Google ID token, not a Supabase JWT.

## Endpoints (all POST unless noted)

Headers for protected calls: `Authorization: Bearer <google_id_token>`,
`apikey: <SUPABASE_ANON_KEY>`.

- `create-or-update-user` → `{ id, email, full_name, preferred_language, theme_mode }`
- `create-case` (body: optional case fields) → created case
- `get-case` (body: optional `{ case_id }`) → the case (or current case)
- `update-case` (body: `{ case_id, ...fields }`) → updated case (claim recalculated)
- `delete-case` (body: `{ case_id }`) → `{ deleted: true }` (soft delete; purged later)
- `create-upload` (body: `{ case_id, mime_type, size_bytes }`) → `{ storage_path, signed_url, token }`
- `complete-upload` (body: evidence metadata + `storage_path`) → `{ id }`
- `delete-evidence` (body: `{ evidence_id }`) → `{ deleted: true }` (row is
  soft-deleted, the storage object removed, then the row hard-deleted; if
  object removal fails the purge retries it, so objects are never orphaned)
- `send-demand-letter` (body: `{ case_id, language, recipient_email, subject, letter_html, pdf_base64? }`) → delivery result
- `delete-account` → `{ deleted: true }` (soft delete; purged later)
- `keep-alive` (GET/POST, no auth) → `{ ok: true }`
- `purge-deleted` (no token; header `x-purge-secret: <PURGE_SECRET>`) → `{ ok, retention_days, cutoff, cases, users, evidence, objects }`

Errors: `{ error: { code, message } }` with an appropriate status; internal
details and stack traces are never returned.
