// create-upload — validates ownership, file type/size, and per-case quota, then
// returns a short-lived signed upload URL (§12.1, FR-EVD-01/02/03). No evidence
// metadata is written yet, so an interrupted upload leaves no record (§16). The
// storage key is a random object id, not the filename (FR-EVD-07).
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import {
  readJsonObject,
  requirePositiveInt,
  requireString,
} from "../_shared/validation.ts";
import { requireCaseId, requireOwnedCase } from "../_shared/cases.ts";
import { assertUploadAllowed, extensionForMime } from "../_shared/evidence.ts";
import { createSignedUpload } from "../_shared/storage.ts";

Deno.serve(withAuth(async ({ userId, req }) => {
  const body = await readJsonObject(req);
  const caseId = requireCaseId(body);
  await requireOwnedCase(caseId, userId);

  const mimeType = requireString(body, "mime_type", { maxLength: 128 });
  const sizeBytes = requirePositiveInt(body, "size_bytes");

  await assertUploadAllowed(caseId, userId, { mimeType, sizeBytes });

  const ext = extensionForMime(mimeType);
  const objectId = crypto.randomUUID();
  const storagePath = `${userId}/${caseId}/${objectId}.${ext}`;
  const signed = await createSignedUpload(storagePath);

  return jsonResponse({
    storage_path: storagePath,
    signed_url: signed.signedUrl,
    token: signed.token,
  });
}));
