// Private evidence storage access (§12.1). Uses the Supabase service role
// (auto-injected into Edge Functions as SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY)
// to issue short-lived signed URLs. The bucket is private; anonymous/direct
// client access is denied (NFR-SEC-04/05). Only functions that have already
// verified the Google token AND resource ownership may call these.
import { createClient, type SupabaseClient } from "@supabase/supabase-js";

const BUCKET = "evidence";

let client: SupabaseClient | null = null;

function admin(): SupabaseClient {
  if (client) return client;
  const url = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !serviceKey) {
    throw new Error("Supabase service credentials are not set");
  }
  client = createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  return client;
}

export interface SignedUpload {
  path: string;
  signedUrl: string;
  token: string;
}

export async function createSignedUpload(path: string): Promise<SignedUpload> {
  const { data, error } = await admin()
    .storage
    .from(BUCKET)
    .createSignedUploadUrl(path);
  if (error || !data) throw new Error("Failed to create signed upload URL");
  return { path: data.path ?? path, signedUrl: data.signedUrl, token: data.token };
}

/**
 * Short-lived signed download URL (NFR-SEC-11: links expire quickly). When
 * [downloadFilename] is provided the URL forces a download with that name;
 * otherwise the object is served inline (used for image preview).
 */
export async function createSignedDownload(
  path: string,
  expiresInSeconds: number,
  downloadFilename?: string,
): Promise<string> {
  const { data, error } = await admin()
    .storage
    .from(BUCKET)
    .createSignedUrl(
      path,
      expiresInSeconds,
      downloadFilename ? { download: downloadFilename } : undefined,
    );
  if (error || !data) throw new Error("Failed to create signed download URL");
  return data.signedUrl;
}

export async function removeObjects(paths: string[]): Promise<void> {
  if (paths.length === 0) return;
  await admin().storage.from(BUCKET).remove(paths);
}
