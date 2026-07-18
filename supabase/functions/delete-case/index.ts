// delete-case — soft-deletes an owned case (FR-CASE-04, §23.3). The case
// disappears from the app immediately; its rows and evidence objects are kept
// until the scheduled `purge-deleted` job removes them after the retention
// window, allowing recovery from accidental deletion.
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import { readJsonObject } from "../_shared/validation.ts";
import { deleteCase, requireCaseId } from "../_shared/cases.ts";
import { writeAudit } from "../_shared/audit.ts";

Deno.serve(withAuth(async ({ userId, req }) => {
  const body = await readJsonObject(req);
  const caseId = requireCaseId(body);

  await deleteCase(userId, caseId);

  await writeAudit({
    userId,
    caseId,
    action: "case.delete",
    entityType: "case",
    entityId: caseId,
  });
  return jsonResponse({ deleted: true });
}));
