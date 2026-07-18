// delete-evidence — removes an owned evidence record and its storage object
// (FR-EVD-06). Soft-delete first (immediately hidden and out of quota), then
// remove the object, then hard-delete the row. If object removal fails, the
// soft-deleted row is kept so the scheduled purge retries the removal —
// otherwise the object would be orphaned with nothing referencing it.
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import { readJsonObject, requireString } from "../_shared/validation.ts";
import { hardDeleteEvidence, softDeleteEvidence } from "../_shared/evidence.ts";
import { removeObjects } from "../_shared/storage.ts";
import { writeAudit } from "../_shared/audit.ts";

Deno.serve(withAuth(async ({ userId, req }) => {
  const body = await readJsonObject(req);
  const evidenceId = requireString(body, "evidence_id", { maxLength: 64 });

  const objectPath = await softDeleteEvidence(userId, evidenceId);
  try {
    await removeObjects([objectPath]);
    await hardDeleteEvidence(userId, evidenceId);
  } catch (_error) {
    // Object removal (or the final row delete) failed: leave the soft-deleted
    // row in place; purge-deleted retries the removal after the grace window.
  }

  await writeAudit({
    userId,
    action: "evidence.delete",
    entityType: "evidence",
    entityId: evidenceId,
  });
  return jsonResponse({ deleted: true });
}));
