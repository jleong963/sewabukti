// Safe audit logging (§13.7). Stores non-sensitive metadata only — never
// tokens, API keys, full document contents, or unnecessary identity numbers
// (NFR-SEC-10). Auditing must never break the main request flow.
import { turso } from "./turso.ts";

export interface AuditEntry {
  userId?: string;
  caseId?: string;
  action: string;
  entityType?: string;
  entityId?: string;
  metadata?: Record<string, unknown>;
}

export async function writeAudit(entry: AuditEntry): Promise<void> {
  try {
    await turso().execute({
      sql:
        `INSERT INTO audit_events
           (id, user_id, case_id, action, entity_type, entity_id, metadata, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      args: [
        crypto.randomUUID(),
        entry.userId ?? null,
        entry.caseId ?? null,
        entry.action,
        entry.entityType ?? null,
        entry.entityId ?? null,
        entry.metadata ? JSON.stringify(entry.metadata) : null,
        new Date().toISOString(),
      ],
    });
  } catch (_error) {
    // Swallow: an audit failure must not fail the user's operation.
  }
}
