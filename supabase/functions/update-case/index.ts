// update-case — updates whitelisted fields of an owned case and recalculates
// the claimed amount (FR-CASE-03/05/06).
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import { readJsonObject } from "../_shared/validation.ts";
import { requireCaseId, updateCase } from "../_shared/cases.ts";
import { writeAudit } from "../_shared/audit.ts";

Deno.serve(withAuth(async ({ userId, req }) => {
  const body = await readJsonObject(req);
  const caseId = requireCaseId(body);

  const updated = await updateCase(userId, caseId, body);
  await writeAudit({
    userId,
    caseId,
    action: "case.update",
    entityType: "case",
    entityId: caseId,
  });
  return jsonResponse(updated);
}));
