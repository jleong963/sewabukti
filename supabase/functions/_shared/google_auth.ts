// Google ID-token verification — the security cornerstone (§14, FR-AUTH-04/06).
//
// Every protected function MUST call verifyGoogleIdToken BEFORE any application
// logic and MUST fail closed if verification cannot be completed
// (NFR-SEC-24/25). A decoded-but-unverified token is never trusted.
import { createRemoteJWKSet, jwtVerify, type JWTPayload } from "jose";

// Google's OpenID issuers (with and without scheme).
const GOOGLE_ISSUERS = ["https://accounts.google.com", "accounts.google.com"];

// Remote JWKS. `jose` caches keys per the endpoint's Cache-Control and refreshes
// on key rotation; if a matching key cannot be fetched, verification throws and
// we fail closed (NFR-SEC-25).
const JWKS = createRemoteJWKSet(
  new URL("https://www.googleapis.com/oauth2/v3/certs"),
);

export interface GoogleIdentity {
  /** Stable Google account key (`sub`); never the email (FR-AUTH-08). */
  sub: string;
  email: string;
  emailVerified: boolean;
  name?: string;
}

export class AuthError extends Error {
  constructor(readonly code: string, message: string) {
    super(message);
    this.name = "AuthError";
  }
}

/** Extracts the bearer token; throws AuthError when absent (FR-AUTH-03). */
export function bearerToken(req: Request): string {
  const header = req.headers.get("Authorization") ?? "";
  const match = header.match(/^Bearer\s+(.+)$/i);
  if (!match) throw new AuthError("missing_token", "Missing bearer token");
  return match[1].trim();
}

/**
 * Verifies signature, issuer, audience (== GOOGLE_OAUTH_CLIENT_ID), and expiry, then
 * requires a verified email. Returns the trusted identity or throws AuthError.
 */
export async function verifyGoogleIdToken(token: string): Promise<GoogleIdentity> {
  const audience = Deno.env.get("GOOGLE_OAUTH_CLIENT_ID");
  if (!audience) {
    // Misconfiguration must not be treated as an auth failure downstream.
    throw new AuthError("server_misconfigured", "GOOGLE_OAUTH_CLIENT_ID is not set");
  }

  let payload: JWTPayload;
  try {
    const result = await jwtVerify(token, JWKS, {
      issuer: GOOGLE_ISSUERS,
      audience, // expected audience equals the configured client id (FR-AUTH-07)
      // jwtVerify also enforces `exp`/`nbf`.
    });
    payload = result.payload;
  } catch (_error) {
    // Do not leak cryptographic details (NFR-SEC-24). Fail closed.
    throw new AuthError("invalid_token", "Token verification failed");
  }

  const sub = typeof payload.sub === "string" ? payload.sub : "";
  const email = typeof payload.email === "string" ? payload.email : "";
  const emailVerified = payload.email_verified === true ||
    payload.email_verified === "true";
  const name = typeof payload.name === "string" ? payload.name : undefined;

  if (!sub) throw new AuthError("invalid_token", "Token missing subject");
  if (!email || !emailVerified) {
    throw new AuthError("email_unverified", "Email is not verified");
  }

  return { sub, email, emailVerified, name };
}
