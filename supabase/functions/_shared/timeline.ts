// Chronology / timeline repository (§10.5, FR-CHR-*). Events belong to a case
// and user (ownership enforced). Events may link to evidence in the same case
// via the timeline_evidence join. All queries are parameterised (§14.8).
import { turso } from "./turso.ts";
import { ApiError } from "./handler.ts";

const EVENT_COLUMNS = [
  "id",
  "case_id",
  "event_date",
  "event_time",
  "title",
  "description",
  "sort_order",
] as const;

type Row = Record<string, unknown>;

function rowToEvent(row: Row, evidenceIds: string[]): Record<string, unknown> {
  return {
    id: row.id,
    event_date: row.event_date,
    event_time: row.event_time ?? null,
    title: row.title,
    description: row.description ?? null,
    sort_order: row.sort_order ?? 0,
    evidence_ids: evidenceIds,
  };
}

/** Filters the given ids to evidence that belongs to this case + user. */
async function _ownedEvidenceIds(
  caseId: string,
  userId: string,
  ids: string[],
): Promise<string[]> {
  if (ids.length === 0) return [];
  const result = await turso().execute({
    sql: `SELECT id FROM evidence_files
           WHERE case_id = ? AND user_id = ? AND deleted_at IS NULL`,
    args: [caseId, userId],
  });
  const owned = new Set(
    result.rows.map((r) => String((r as unknown as Row).id)),
  );
  return ids.filter((id) => owned.has(id));
}

async function _setLinks(
  eventId: string,
  caseId: string,
  userId: string,
  evidenceIds: string[],
): Promise<void> {
  const db = turso();
  await db.execute({
    sql: "DELETE FROM timeline_evidence WHERE timeline_event_id = ?",
    args: [eventId],
  });
  for (const evidenceId of await _ownedEvidenceIds(caseId, userId, evidenceIds)) {
    await db.execute({
      sql: `INSERT INTO timeline_evidence (timeline_event_id, evidence_file_id)
            VALUES (?, ?)`,
      args: [eventId, evidenceId],
    });
  }
}

async function _requireOwnedEvent(
  eventId: string,
  userId: string,
): Promise<Row> {
  const result = await turso().execute({
    sql: `SELECT ${EVENT_COLUMNS.join(", ")} FROM timeline_events
           WHERE id = ? AND user_id = ?`,
    args: [eventId, userId],
  });
  if (result.rows.length === 0) {
    throw new ApiError(404, "event_not_found", "Timeline event not found");
  }
  return result.rows[0] as unknown as Row;
}

export async function listTimeline(
  caseId: string,
  userId: string,
): Promise<Array<Record<string, unknown>>> {
  const db = turso();
  const events = await db.execute({
    sql: `SELECT ${EVENT_COLUMNS.join(", ")} FROM timeline_events
           WHERE case_id = ? AND user_id = ?
           ORDER BY sort_order ASC, event_date ASC`,
    args: [caseId, userId],
  });
  // Links to soft-deleted evidence are excluded: the file is already invisible
  // everywhere else and its row disappears at the next purge.
  const links = await db.execute({
    sql: `SELECT te.timeline_event_id AS event_id, te.evidence_file_id AS evidence_id
            FROM timeline_evidence te
            JOIN timeline_events e ON e.id = te.timeline_event_id
            JOIN evidence_files ef
              ON ef.id = te.evidence_file_id AND ef.deleted_at IS NULL
           WHERE e.case_id = ? AND e.user_id = ?`,
    args: [caseId, userId],
  });

  const byEvent = new Map<string, string[]>();
  for (const link of links.rows) {
    const row = link as unknown as Row;
    const eventId = String(row.event_id);
    const list = byEvent.get(eventId) ?? [];
    list.push(String(row.evidence_id));
    byEvent.set(eventId, list);
  }

  return events.rows.map((r) => {
    const row = r as unknown as Row;
    return rowToEvent(row, byEvent.get(String(row.id)) ?? []);
  });
}

export interface EventInput {
  eventDate: string;
  eventTime?: string;
  title: string;
  description?: string;
  evidenceIds: string[];
}

export async function createTimelineEvent(
  caseId: string,
  userId: string,
  input: EventInput,
): Promise<string> {
  const db = turso();
  const id = crypto.randomUUID();
  const now = new Date().toISOString();

  // Append after the current max sort order.
  const max = await db.execute({
    sql: `SELECT COALESCE(MAX(sort_order), -1) + 1 AS next
            FROM timeline_events WHERE case_id = ? AND user_id = ?`,
    args: [caseId, userId],
  });
  const sortOrder = Number((max.rows[0] as unknown as Row).next ?? 0);

  await db.execute({
    sql: `INSERT INTO timeline_events
            (id, case_id, user_id, event_date, event_time, title, description,
             sort_order, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    args: [
      id,
      caseId,
      userId,
      input.eventDate,
      input.eventTime ?? null,
      input.title,
      input.description ?? null,
      sortOrder,
      now,
      now,
    ],
  });
  await _setLinks(id, caseId, userId, input.evidenceIds);
  return id;
}

export async function updateTimelineEvent(
  eventId: string,
  userId: string,
  input: EventInput,
): Promise<void> {
  const existing = await _requireOwnedEvent(eventId, userId);
  const caseId = String(existing.case_id);
  await turso().execute({
    sql: `UPDATE timeline_events
             SET event_date = ?, event_time = ?, title = ?, description = ?,
                 updated_at = ?
           WHERE id = ? AND user_id = ?`,
    args: [
      input.eventDate,
      input.eventTime ?? null,
      input.title,
      input.description ?? null,
      new Date().toISOString(),
      eventId,
      userId,
    ],
  });
  await _setLinks(eventId, caseId, userId, input.evidenceIds);
}

export async function deleteTimelineEvent(
  eventId: string,
  userId: string,
): Promise<void> {
  await _requireOwnedEvent(eventId, userId);
  await turso().execute({
    sql: "DELETE FROM timeline_events WHERE id = ? AND user_id = ?",
    args: [eventId, userId],
  });
}

/** Applies a new manual order (FR-CHR-04): sort_order = position in the list. */
export async function reorderTimeline(
  caseId: string,
  userId: string,
  orderedIds: string[],
): Promise<void> {
  const db = turso();
  const now = new Date().toISOString();
  for (let i = 0; i < orderedIds.length; i++) {
    await db.execute({
      sql: `UPDATE timeline_events SET sort_order = ?, updated_at = ?
             WHERE id = ? AND case_id = ? AND user_id = ?`,
      args: [i, now, orderedIds[i], caseId, userId],
    });
  }
}
