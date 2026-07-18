// create-download — issues a short-lived signed URL for an owned evidence file
// (§12.1, FR-EVD-05, NFR-SEC-11). With `download: true` the URL forces a file
// download; otherwise the object is served inline (image preview).
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import { readJsonObject, requireString } from "../_shared/validation.ts";
import { getEvidenceForDownload } from "../_shared/evidence.ts";
import { createSignedDownload } from "../_shared/storage.ts";

const EXPIRES_SECONDS = 120;

Deno.serve(withAuth(async ({ userId, req }) => {
  const body = await readJsonObject(req);
  const evidenceId = requireString(body, "evidence_id", { maxLength: 64 });
  const forceDownload = body.download === true;

  const info = await getEvidenceForDownload(evidenceId, userId);
  const url = await createSignedDownload(
    info.storagePath,
    EXPIRES_SECONDS,
    forceDownload ? info.originalFilename : undefined,
  );

  return jsonResponse({
    url,
    expires_in: EXPIRES_SECONDS,
    mime_type: info.mimeType,
    filename: info.originalFilename,
  });
}));
