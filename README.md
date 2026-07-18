# SewaBukti

**Susun bukti. Tuntut deposit anda.** — Build your case. Claim your deposit.

SewaBukti is a free, responsive **Flutter Web** application that helps
Malaysian residential tenants recover their rental deposit when a landlord,
agent, or management company delays, reduces, or refuses to return it.

## What is SewaBukti?

Getting a deposit back in Malaysia often comes down to preparation: knowing
exactly how much is owed, having the tenancy documents and photos in one
place, presenting a clear timeline of what happened, and making a formal,
written demand. Most tenants have the evidence — scattered across chat
threads, email, and camera rolls — but no easy way to turn it into a case.

SewaBukti walks a tenant through exactly that. In one place you can:

1. **Sign in with Google** — no separate account or password to manage.
2. **Describe the tenancy** in a guided questionnaire (property, parties,
   deposits paid, deductions claimed) — the app calculates the outstanding
   amount for you.
3. **Upload your evidence** (tenancy agreement, receipts, photos, chat
   exports) into a private, secure store.
4. **Build a chronology** of events — move-in, requests, promises, refusals —
   and link each event to the evidence that proves it.
5. **Generate a demand letter** in English, Bahasa Melayu, or Chinese;
   download it as a PDF or email it directly to the landlord.
6. **Export an indexed evidence bundle** — a single PDF that presents your
   documents in order, ready for negotiation or filing.
7. **Follow claim-route guidance** on where to take the matter next (for
   example the Small Claims Court), including a check of your claim amount
   against the small-claims ceiling for your region.

> **Disclaimer:** SewaBukti is an evidence-organisation and
> document-preparation tool. It is **not** a law firm, court, or government
> service; it does not provide legal advice or representation, and it does not
> guarantee repayment or court acceptance.

## Features

- **Direct Google Sign-In** — the official Google Identity Services button
  with full server-side ID-token verification (signature, issuer, audience,
  expiry, verified email). Supabase Auth is not used.
- **Case questionnaire wizard** — step-by-step tenancy questions with
  save-per-step, server-side claim recalculation, and the claimant identity
  number encrypted at rest (AES-GCM).
- **Deposit calculator** — tracks security/utility deposits, payments, and
  disputed deductions; money is handled as integer sen so amounts never drift.
- **Evidence vault** — uploads go to a **private** storage bucket via
  short-lived signed URLs. PDF, JPEG, PNG, WebP, and plain-text files up to
  10 MB, with type/size/quota limits enforced on both client and server.
- **Chronology builder** — add, edit, reorder, and delete timeline events and
  link them to uploaded evidence.
- **Demand-letter generator** — a formal letter in any of the three languages,
  downloadable as PDF or sent by email server-side (with daily send limits).
- **Indexed evidence bundle** — one consolidated, indexed PDF of the whole
  case, generated entirely in the browser.
- **Claim-route guidance** — region-aware pointers to the right court or
  portal, plus legal/info pages about the process.
- **Trilingual UI** — English (default), Bahasa Melayu, and Simplified
  Chinese, with English fallback and a landing-page language selector.
- **Light/dark theme** — sea-blue Material 3 design with Noto Sans / Noto
  Sans SC; language and theme preferences persist and sync to your profile.
- **Privacy controls** — export your case data as JSON, delete a case or your
  whole account (soft delete, permanently purged after a 30-day retention
  window).

## Tech stack

| Layer | Technology |
|---|---|
| Frontend | Flutter Web / Dart |
| State | Riverpod (`Notifier`) |
| Routing | `go_router` |
| Auth | Direct Google Sign-In (GIS / OIDC) — **not** Supabase Auth |
| Structured data | Turso (libSQL) via Edge Functions |
| Evidence storage | Supabase Storage (private bucket, signed URLs) |
| Server functions | Supabase Edge Functions (Deno) |
| Email | Gmail SMTP via `nodemailer` (server-side only) |
| PDF | Dart `pdf` package (in-browser) |
| Hosting | Vercel (Hobby for the non-commercial beta) |
| CI/CD | GitHub Actions → Vercel |

## Getting started (developer setup)

Follow these steps to go from a fresh machine to the app running locally.

### 1. Install the prerequisites

| Tool | Version | Notes |
|---|---|---|
| [Git](https://git-scm.com/downloads) | any recent | to clone the repository |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | **3.44.x** (bundles Dart 3.12.x; CI pins 3.44.4) | add `flutter` to your `PATH` |
| Google Chrome | any recent | Flutter's web debug target |

Verify the toolchain:

```bash
flutter --version   # expect Flutter 3.44.x / Dart 3.12.x
flutter doctor      # "Chrome - develop for the web" should be ticked
```

An IDE with the Flutter plugin (VS Code, Android Studio, or IntelliJ) is
recommended but not required.

### 2. Clone the repository

```bash
git clone https://github.com/jleong963/sewabukti.git
cd sewabukti
```

### 3. Fetch the dependencies

```bash
flutter pub get
```

### 4. Generate the localisation files

```bash
flutter gen-l10n
```

This is usually automatic (`generate: true` in `pubspec.yaml`), but running it
once explicitly ensures the generated `AppLocalizations` code exists before
your IDE analyses the project.

### 5. Run the app — preview mode (no backend needed)

```bash
flutter run -d chrome
```

That's it — the app opens in Chrome. With no configuration passed, SewaBukti
runs in **preview mode**:

- The landing page shows a neutral preview sign-in control instead of the
  real Google button (Google Identity Services is unconfigured).
- All features work, backed by **local browser storage** instead of the cloud
  backend — cases, timeline events, and letters stay on your machine.

Preview mode is the fastest way to explore the full UI and is what the test
suite uses. Hot reload works as usual (`r` in the terminal, or your IDE).

### 6. Run the checks

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

These are the same checks CI runs on every pull request.

## Connecting a real backend (optional)

Preview mode needs nothing, but to exercise real sign-in, storage, and email
you need the cloud services configured. All four have usable free tiers.

1. **Google OAuth client** — in [Google Cloud Console](https://console.cloud.google.com/apis/credentials),
   create an OAuth **Web application** client ID and add your dev origin
   (e.g. `http://localhost:8080`) to *Authorized JavaScript origins*. GIS
   validates the page origin, so pin the port when you run (step 5 below).
2. **Turso database** — create a database and apply the schema:

   ```bash
   turso db create sewabukti
   turso db shell sewabukti < database/schema.sql
   turso db show sewabukti --url      # → TURSO_DATABASE_URL
   turso db tokens create sewabukti   # → TURSO_AUTH_TOKEN
   ```

3. **Supabase project** — create a project, then:
   - Run `database/storage_setup.sql` in the SQL editor (creates the
     **private** `evidence` bucket).
   - Deploy the Edge Functions and set their secrets (Turso, Gmail,
     `APP_ENCRYPTION_KEY`, …):

     ```bash
     supabase link --project-ref <your-project-ref>
     supabase functions deploy
     supabase secrets set GOOGLE_OAUTH_CLIENT_ID=... TURSO_DATABASE_URL=... TURSO_AUTH_TOKEN=... GMAIL_USER=... GMAIL_APP_PASSWORD=... ...
     ```

     See **[`supabase/functions/README.md`](supabase/functions/README.md)**
     for the full secrets table, the encryption-key setup, and local
     function serving.
4. **Gmail** (only for emailing demand letters) — on the sending Google
   account, enable 2-Step Verification and create an **App Password**
   (Google Account → Security → App passwords). Set the mailbox as the
   `GMAIL_USER` function secret and the 16-character App Password as
   `GMAIL_APP_PASSWORD`. Unlike a shared test sender, Gmail delivers to any
   recipient with no domain to verify.

Then configure the client. Copy the template and fill in the **public**
values (`.env` is git-ignored):

```bash
cp .env.example .env
```

```dotenv
APP_ENV=development
SUPABASE_URL=https://<your-project-ref>.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
GOOGLE_OAUTH_CLIENT_ID=<your-client-id>.apps.googleusercontent.com
KEEPALIVE_INTERVAL_SECONDS=0
```

And run with a pinned port matching your Google OAuth origin:

```bash
flutter run -d chrome --web-port 8080 --dart-define-from-file=.env
```

**Security boundary:** every value compiled into a Flutter Web build is
inspectable by users, so only these public values may reach the client.
Server-side secrets (`TURSO_AUTH_TOKEN`, `GMAIL_APP_PASSWORD`,
`SUPABASE_SERVICE_ROLE_KEY`, `APP_ENCRYPTION_KEY`, `PURGE_SECRET`,
`VERCEL_TOKEN`, …) live only in the Supabase dashboard or GitHub Actions
Secrets — never in the repo, a real `.env` used for builds, or client code.

## Building for production

```bash
flutter build web --release \
  --dart-define=APP_ENV=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=GOOGLE_OAUTH_CLIENT_ID=...
```

Output is `build/web`, ready for any static host.

## Deployment and CI/CD

The beta is hosted on Vercel at **https://sewabukti.vercel.app**. The default
branch is **`master`**.

| Workflow | Trigger | What it does |
|---|---|---|
| `ci.yml` | pull request | format, analyse, test, production web build (no deploy) |
| `deploy-vercel.yml` | push to `master` (+ manual) | reruns checks, builds once, deploys the artifact to Vercel |
| `keep-alive.yml` | cron | pings the `keep-alive` Edge Function so the free Supabase project never pauses |
| `purge-deleted.yml` | daily cron | invokes `purge-deleted` (guarded by `PURGE_SECRET`) to permanently remove data soft-deleted beyond the retention window |

Configure under **GitHub → Settings → Secrets and variables → Actions**:

- **Secrets:** `VERCEL_TOKEN`, `SUPABASE_ACCESS_TOKEN`, `TURSO_AUTH_TOKEN`,
  `GMAIL_USER`, `GMAIL_APP_PASSWORD`, `PURGE_SECRET`.
- **Variables (non-sensitive):** `APP_ENV`, `VERCEL_ORG_ID`,
  `VERCEL_PROJECT_ID`, `SUPABASE_PROJECT_REF`, `SUPABASE_URL`,
  `SUPABASE_ANON_KEY`, `TURSO_DATABASE_URL`, `GOOGLE_OAUTH_CLIENT_ID`,
  `KEEPALIVE_INTERVAL_SECONDS`, `INACTIVE_TIMEOUT`.

The production origin (`https://sewabukti.vercel.app`, no trailing slash)
must be referenced in two external places:

- **Supabase** — set the `APP_ORIGIN` function secret so the Edge Functions
  restrict CORS to the app (defaults to `*` otherwise).
- **Google Cloud Console** — add it to the OAuth client's *Authorized
  JavaScript origins*, or sign-in fails in production.

**Email sender note:** demand-letter emails are sent through Gmail SMTP
(`smtp.gmail.com`, port 465, implicit TLS) authenticated with a Google
**App Password** — no custom domain or DNS verification is required, and Gmail
delivers to any recipient. The From address is the `GMAIL_USER` mailbox; set
the optional `GMAIL_FROM` only to change the display name. Keep total sends
within Gmail's daily cap (≈500/day for a free account; the app's own
`MAX_PER_APP_PER_DAY` of 80 stays well under it).

**Keeping Supabase awake:** free-tier projects pause after inactivity. The
client pings the `keep-alive` function every `KEEPALIVE_INTERVAL_SECONDS`
while the app is open (`0` disables), and the scheduled `keep-alive.yml`
workflow covers zero-user periods — the latter is the real safety net.

**Session inactivity auto-logout:** while signed in, the client signs the user
out after `INACTIVE_TIMEOUT` seconds with no pointer or keyboard activity (`0`
disables). It is a client-side convenience/hygiene control — the Google ID
token's own expiry remains the real security boundary — so a returning user
lands back on the sign-in page with a short "signed out due to inactivity"
notice.

## Database

[`database/schema.sql`](database/schema.sql) is the Turso (libSQL) schema and
[`database/storage_setup.sql`](database/storage_setup.sql) creates the private
evidence bucket. Money is stored as integer **sen** (1 RM = 100 sen).

## Project structure

```
lib/
  main.dart                      # entrypoint; loads prefs, ProviderScope
  src/
    app.dart                     # MaterialApp.router
    core/
      auth/                      # auth state + Google Identity Services (web)
      config/app_config.dart     # public dart-define values only
      constants/                 # storage/email limits, legal config
      download/                  # browser file download (case export)
      formatting/                # RM currency + localised dates
      keepalive/                 # client heartbeat (anti-pause)
      legal/                     # privacy/terms/help/claim-route content
      preferences/               # locale + theme controllers (persisted)
      routing/                   # go_router + route paths
      security/                  # filename sanitisation
      theme/                     # sea-blue light/dark theme + brand tokens
    features/
      account/                   # case data export (JSON)
      bundle/                    # indexed evidence-bundle PDF
      cases/                     # case model, wizard, deposit calculator
      chronology/                # timeline events
      dashboard/                 # dashboard + status tiles
      demand_letter/             # letter model, PDF/HTML, send
      evidence/                  # upload/preview/delete evidence
      landing/                   # sign-in / product intro
      legal/                     # legal & info pages
      route/                     # claim-route guidance
      settings/                  # settings, language, light/dark, data
      shared/widgets/            # wordmark, language selector, legal notice
    l10n/                        # ARB files + generated localisations
database/                        # Turso schema + storage bucket setup
supabase/functions/              # Edge Functions (see its README)
.github/workflows/               # CI, deploy, keep-alive, purge crons
```

## Localisation and theming

UI strings live in `lib/src/l10n/*.arb` (English is the template and
guaranteed fallback). The current Bahasa Melayu and Simplified Chinese
strings are competent working translations, but **legal, procedural,
disclaimer, demand-letter, and email copy must be professionally reviewed
before beta**. Theme tokens are defined in
`lib/src/core/theme/app_colors.dart`; the sea-blue palette targets WCAG 2.1
AA contrast in both light and dark modes.

## Project status

All six MVP phases are **code-complete**. Remaining before beta:

- A live end-to-end run against the deployed backend (the CI/CD workflows
  are scaffolding and have not been exercised yet).
- Professional legal review of the localised copy.

## License

[MIT](LICENSE) © 2026 james.leong
