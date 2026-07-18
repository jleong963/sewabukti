// update-timeline-event — edits an owned chronology event and its evidence links.
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import {
  optionalString,
  readJsonObject,
  requireString,
  stringList,
} from "../_shared/validation.ts";
import { updateTimelineEvent } from "../_shared/timeline.ts";
import { writeAudit } from "../_shared/audit.ts";

Deno.serve(withAuth(async ({ userId, req }) => {
  const body = await readJsonObject(req);
  const eventId = requireString(body, "event_id", { maxLength: 64 });

  await updateTimelineEvent(eventId, userId, {
    eventDate: requireString(body, "event_date", { maxLength: 32 }),
    eventTime: optionalString(body, "event_time", { maxLength: 16 }),
    title: requireString(body, "title", { maxLength: 200 }),
    description: optionalString(body, "description", { maxLength: 5000 }),
    evidenceIds: stringList(body, "evidence_ids"),
  });
  await writeAudit({
    userId,
    action: "timeline.update",
    entityType: "timeline_event",
    entityId: eventId,
  });
  return jsonResponse({ updated: true });
}));
