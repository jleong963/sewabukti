// Retention purge (§23.3, NFR-SEC-15). Permanently removes data that was
// soft-deleted before the cutoff: storage objects first, then the DB rows
// (child rows cascade via foreign keys). Invoked by the scheduled
// `purge-deleted` function; never touches data still inside the grace window.
import { turso } from "./turso.ts";
import { removeObjects } from "./storage.ts";

export interface PurgeResult {
  cases: number;
  users: number;
  evidence: number;
  objects: number;
}

function idsOf(rows: unknown[]): string[] {
  return rows.map((r) => String((r as Record<string, unknown>).id));
}

function pathsOf(rows: unknown[]): string[] {
  return rows.map((r) => String((r as Record<string, unknown>).storage_path));
}

/** Best-effort object removal; DB rows are purged regardless of storage errors. */
async function removeQuietly(paths: string[]): Promise<number> {
  if (paths.length === 0) return 0;
  try {
    await removeObjects(paths);
  } catch (_error) {
    // Orphaned objects are swept by a later run; do not block the DB purge.
  }
  return paths.length;
}

/**
 * Hard-deletes cases and users soft-deleted strictly before [cutoffIso],
 * removing their evidence storage objects. Returns counts for logging.
 */
export async function purgeExpired(cutoffIso: string): Promise<PurgeResult> {
  const db = turso();
  let objects = 0;

  // 1) Individually soft-deleted evidence whose object removal failed at
  //    delete time (delete-evidence keeps the row so the path is not lost).
  //    Rows are removed only once their objects are confirmed gone, so a
  //    failing storage call just defers the row to the next run.
  const evidence = await db.execute({
    sql: `SELECT id, storage_path FROM evidence_files
           WHERE deleted_at IS NOT NULL AND deleted_at < ?`,
    args: [cutoffIso],
  });
  let purgedEvidence = 0;
  if (evidence.rows.length > 0) {
    try {
      await removeObjects(pathsOf(evidence.rows));
      objects += evidence.rows.length;
      for (const id of idsOf(evidence.rows)) {
        await db.execute({
          sql: "DELETE FROM evidence_files WHERE id = ?",
          args: [id],
        });
        purgedEvidence++;
      }
    } catch (_error) {
      // Storage unavailable: keep the rows (and their paths) for the next run.
    }
  }

  // 2) Individually soft-deleted cases (whose owner is still active).
  const cases = await db.execute({
    sql: "SELECT id FROM cases WHERE deleted_at IS NOT NULL AND deleted_at < ?",
    args: [cutoffIso],
  });
  for (const caseId of idsOf(cases.rows)) {
    const caseEvidence = await db.execute({
      sql: "SELECT storage_path FROM evidence_files WHERE case_id = ?",
      args: [caseId],
    });
    objects += await removeQuietly(pathsOf(caseEvidence.rows));
    await db.execute({ sql: "DELETE FROM cases WHERE id = ?", args: [caseId] });
  }

  // 3) Soft-deleted accounts (cascades to their cases/evidence/timeline/etc.).
  const users = await db.execute({
    sql: "SELECT id FROM users WHERE deleted_at IS NOT NULL AND deleted_at < ?",
    args: [cutoffIso],
  });
  for (const userId of idsOf(users.rows)) {
    const userEvidence = await db.execute({
      sql: "SELECT storage_path FROM evidence_files WHERE user_id = ?",
      args: [userId],
    });
    objects += await removeQuietly(pathsOf(userEvidence.rows));
    await db.execute({ sql: "DELETE FROM users WHERE id = ?", args: [userId] });
  }

  return {
    cases: cases.rows.length,
    users: users.rows.length,
    evidence: purgedEvidence,
    objects,
  };
}
