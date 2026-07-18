// delete-timeline-event — removes an owned chronology event (links cascade).
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import { readJsonObject, requireString } from "../_shared/validation.ts";
import { deleteTimelineEvent } from "../_shared/timeline.ts";
import { writeAudit } from "../_shared/audit.ts";

Deno.serve(withAuth(async ({ userId, req }) => {
  const body = await readJsonObject(req);
  const eventId = requireString(body, "event_id", { maxLength: 64 });
  await deleteTimelineEvent(eventId, userId);
  await writeAudit({
    userId,
    action: "timeline.delete",
    entityType: "timeline_event",
    entityId: eventId,
  });
  return jsonResponse({ deleted: true });
}));
