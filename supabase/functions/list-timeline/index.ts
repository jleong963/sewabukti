// list-timeline — returns a case's chronology events with linked evidence ids.
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import { readJsonObject } from "../_shared/validation.ts";
import { requireCaseId, requireOwnedCase } from "../_shared/cases.ts";
import { listTimeline } from "../_shared/timeline.ts";

Deno.serve(withAuth(async ({ userId, req }) => {
  const body = await readJsonObject(req);
  const caseId = requireCaseId(body);
  await requireOwnedCase(caseId, userId);
  return jsonResponse({ events: await listTimeline(caseId, userId) });
}));
