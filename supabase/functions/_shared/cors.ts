// CORS handling for browser calls from the Flutter Web app.
// The bearer token (Google ID token) is the credential — not cookies — so a
// restricted origin is set from APP_ORIGIN when available.

const ALLOWED_ORIGIN = Deno.env.get("APP_ORIGIN") ?? "*";

export const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Vary": "Origin",
};

/** Returns a 204 preflight response for OPTIONS requests, else null. */
export function handlePreflight(req: Request): Response | null {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }
  return null;
}
