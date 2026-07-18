// reorder-timeline — applies a manual display order to a case's events
// (FR-CHR-04). Body: { case_id, ordered_ids: [] }.
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import { readJsonObject, stringList } from "../_shared/validation.ts";
import { requireCaseId, requireOwnedCase } from "../_shared/cases.ts";
import { reorderTimeline } from "../_shared/timeline.ts";

Deno.serve(withAuth(async ({ userId, req }) => {
  const body = await readJsonObject(req);
  const caseId = requireCaseId(body);
  await requireOwnedCase(caseId, userId);
  await reorderTimeline(caseId, userId, stringList(body, "ordered_ids"));
  return jsonResponse({ reordered: true });
}));
