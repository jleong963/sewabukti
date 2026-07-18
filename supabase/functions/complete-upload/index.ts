// complete-upload — records evidence metadata AFTER the client has uploaded the
// object (FR-EVD-04). Re-validates ownership, type/size/quota (defence in
// depth), and that the storage path belongs to this user + case.
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import { ApiError } from "../_shared/handler.ts";
import {
  optionalString,
  readJsonObject,
  requirePositiveInt,
  requireString,
} from "../_shared/validation.ts";
import { requireCaseId, requireOwnedCase } from "../_shared/cases.ts";
import { assertUploadAllowed, insertEvidence } from "../_shared/evidence.ts";
import { writeAudit } from "../_shared/audit.ts";

Deno.serve(withAuth(async ({ userId, req }) => {
  const body = await readJsonObject(req);
  const caseId = requireCaseId(body);
  await requireOwnedCase(caseId, userId);

  const storagePath = requireString(body, "storage_path", { maxLength: 512 });
  // The path must be within this user's + case's namespace (FR-EVD-05/07).
  if (!storagePath.startsWith(`${userId}/${caseId}/`)) {
    throw new ApiError(400, "invalid_field", "storage_path mismatch");
  }

  const mimeType = requireString(body, "mime_type", { maxLength: 128 });
  const sizeBytes = requirePositiveInt(body, "size_bytes");
  await assertUploadAllowed(caseId, userId, { mimeType, sizeBytes });

  const id = await insertEvidence(userId, {
    caseId,
    category: requireString(body, "category", { maxLength: 64 }),
    storagePath,
    originalFilename: requireString(body, "original_filename", {
      maxLength: 255,
    }),
    mimeType,
    sizeBytes,
    title: optionalString(body, "title", { maxLength: 255 }),
    description: optionalString(body, "description", { maxLength: 5000 }),
    documentDate: optionalString(body, "document_date", { maxLength: 32 }),
    sha256Hash: optionalString(body, "sha256_hash", { maxLength: 128 }),
  });

  await writeAudit({
    userId,
    caseId,
    action: "evidence.create",
    entityType: "evidence",
    entityId: id,
  });
  return jsonResponse({ id }, 201);
}));
