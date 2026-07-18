// Turso (libSQL) client for server-side use only (§8.1). Uses the HTTP-based
// web client so it runs on the Edge runtime without native dependencies.
import { type Client, createClient } from "libsql";

let client: Client | null = null;

export function turso(): Client {
  if (client) return client;
  const url = Deno.env.get("TURSO_DATABASE_URL");
  const authToken = Deno.env.get("TURSO_AUTH_TOKEN");
  if (!url) throw new Error("TURSO_DATABASE_URL is not set");
  client = createClient({ url, authToken });
  return client;
}
