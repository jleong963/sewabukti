// keep-alive — lightweight liveness endpoint pinged by the client heartbeat and
// a scheduled workflow to prevent free-tier inactivity pause. Invoking this
// function is Supabase project activity; the trivial query keeps Turso warm too.
// Intentionally unauthenticated (verify_jwt = false) and does no sensitive work.
import { handlePreflight } from "../_shared/cors.ts";
import { errorResponse, jsonResponse } from "../_shared/http.ts";
import { turso } from "../_shared/turso.ts";

Deno.serve(async (req: Request): Promise<Response> => {
  const preflight = handlePreflight(req);
  if (preflight) return preflight;
  try {
    await turso().execute("SELECT 1");
    return jsonResponse({ ok: true });
  } catch (_error) {
    return errorResponse(503, "unavailable", "Backend not ready");
  }
});
