// purge-deleted — scheduled retention purge (§23.3, NFR-SEC-15). Permanently
// removes accounts and cases that were soft-deleted more than
// RETENTION_PURGE_DAYS ago (default 30), along with their storage objects.
//
// This is a system job, not a user action: it is guarded by a shared secret
// (PURGE_SECRET) rather than a Google token, and is invoked by a scheduled
// GitHub Actions workflow. verify_jwt = false (see config.toml).
import { handlePreflight } from "../_shared/cors.ts";
import { errorResponse, jsonResponse } from "../_shared/http.ts";
import { purgeExpired } from "../_shared/retention.ts";

const DEFAULT_RETENTION_DAYS = 30;

/** Length-checked constant-ish comparison for the shared secret. */
function secretMatches(provided: string | null, expected: string): boolean {
  if (provided == null || provided.length !== expected.length) return false;
  let diff = 0;
  for (let i = 0; i < expected.length; i++) {
    diff |= provided.charCodeAt(i) ^ expected.charCodeAt(i);
  }
  return diff === 0;
}

Deno.serve(async (req: Request): Promise<Response> => {
  const preflight = handlePreflight(req);
  if (preflight) return preflight;
  if (req.method !== "POST") {
    return errorResponse(405, "method_not_allowed", "Use POST");
  }

  const secret = Deno.env.get("PURGE_SECRET");
  if (!secret) {
    return errorResponse(500, "server_misconfigured", "PURGE_SECRET is not set");
  }
  if (!secretMatches(req.headers.get("x-purge-secret"), secret)) {
    return errorResponse(401, "unauthorized", "Invalid purge secret");
  }

  try {
    const days = Number(Deno.env.get("RETENTION_PURGE_DAYS")) ||
      DEFAULT_RETENTION_DAYS;
    const cutoff = new Date(Date.now() - days * 24 * 60 * 60 * 1000)
      .toISOString();
    const result = await purgeExpired(cutoff);
    return jsonResponse({ ok: true, retention_days: days, cutoff, ...result });
  } catch (_error) {
    return errorResponse(500, "purge_failed", "Purge failed");
  }
});
