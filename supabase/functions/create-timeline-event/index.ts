// create-timeline-event — adds a manually entered chronology event (FR-CHR-01).
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import {
  optionalString,
  readJsonObject,
  requireString,
  stringList,
} from "../_shared/validation.ts";
import { requireCaseId, requireOwnedCase } from "../_shared/cases.ts";
import { createTimelineEvent } from "../_shared/timeline.ts";
import { writeAudit } from "../_shared/audit.ts";

Deno.serve(withAuth(async ({ userId, req }) => {
  const body = await readJsonObject(req);
  const caseId = requireCaseId(body);
  await requireOwnedCase(caseId, userId);

  const id = await createTimelineEvent(caseId, userId, {
    eventDate: requireString(body, "event_date", { maxLength: 32 }),
    eventTime: optionalString(body, "event_time", { maxLength: 16 }),
    title: requireString(body, "title", { maxLength: 200 }),
    description: optionalString(body, "description", { maxLength: 5000 }),
    evidenceIds: stringList(body, "evidence_ids"),
  });
  await writeAudit({
    userId,
    caseId,
    action: "timeline.create",
    entityType: "timeline_event",
    entityId: id,
  });
  return jsonResponse({ id }, 201);
}));
