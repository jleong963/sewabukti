// Evidence metadata + quota enforcement (§12.2/12.3, FR-EVD-*). Storage keys use
// random object ids, never the original filename (FR-EVD-07). Limits mirror the
// Flutter client constants but are re-enforced server-side (never trust client).
import { turso } from "./turso.ts";
import { ApiError } from "./handler.ts";

const MAX_FILES_PER_CASE = 20;
const TOTAL_BYTES_PER_CASE = 25 * 1024 * 1024;
const MAX_PDF_BYTES = 10 * 1024 * 1024;
const MAX_IMAGE_BYTES = 5 * 1024 * 1024;
const MAX_TEXT_BYTES = 5 * 1024 * 1024;

const MIME_EXTENSION: Record<string, string> = {
  "application/pdf": "pdf",
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
  "text/plain": "txt",
};

export function extensionForMime(mimeType: string): string {
  const ext = MIME_EXTENSION[mimeType];
  if (!ext) throw new ApiError(415, "unsupported_type", "Unsupported file type");
  return ext;
}

function perFileLimit(mimeType: string): number {
  if (mimeType === "application/pdf") return MAX_PDF_BYTES;
  if (mimeType === "text/plain") return MAX_TEXT_BYTES;
  return MAX_IMAGE_BYTES; // jpeg/png/webp
}

/** Validates type and size, and that the new file fits the per-case quotas. */
export async function assertUploadAllowed(
  caseId: string,
  userId: string,
  file: { mimeType: string; sizeBytes: number },
): Promise<void> {
  if (!MIME_EXTENSION[file.mimeType]) {
    throw new ApiError(415, "unsupported_type", "Unsupported file type");
  }
  if (!Number.isInteger(file.sizeBytes) || file.sizeBytes <= 0) {
    throw new ApiError(400, "invalid_field", "Invalid size");
  }
  if (file.sizeBytes > perFileLimit(file.mimeType)) {
    throw new ApiError(413, "file_too_large", "File exceeds the size limit");
  }

  const result = await turso().execute({
    sql: `SELECT COUNT(*) AS n, COALESCE(SUM(size_bytes), 0) AS total
            FROM evidence_files
           WHERE case_id = ? AND user_id = ? AND deleted_at IS NULL`,
    args: [caseId, userId],
  });
  const row = result.rows[0] as unknown as Record<string, unknown>;
  const count = Number(row.n ?? 0);
  const total = Number(row.total ?? 0);

  if (count + 1 > MAX_FILES_PER_CASE) {
    throw new ApiError(409, "file_count_exceeded", "Too many files for this case");
  }
  if (total + file.sizeBytes > TOTAL_BYTES_PER_CASE) {
    throw new ApiError(409, "storage_quota_exceeded", "Case storage limit reached");
  }
}

export interface EvidenceInput {
  caseId: string;
  category: string;
  storagePath: string;
  originalFilename: string;
  mimeType: string;
  sizeBytes: number;
  title?: string;
  description?: string;
  documentDate?: string;
  sha256Hash?: string;
}

export async function insertEvidence(
  userId: string,
  input: EvidenceInput,
): Promise<string> {
  const id = crypto.randomUUID();
  await turso().execute({
    sql: `INSERT INTO evidence_files
            (id, case_id, user_id, category, title, description, document_date,
             original_filename, storage_path, mime_type, size_bytes, sha256_hash,
             uploaded_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    args: [
      id,
      input.caseId,
      userId,
      input.category,
      input.title ?? null,
      input.description ?? null,
      input.documentDate ?? null,
      input.originalFilename,
      input.storagePath,
      input.mimeType,
      input.sizeBytes,
      input.sha256Hash ?? null,
      new Date().toISOString(),
    ],
  });
  return id;
}

/**
 * Verifies ownership and soft-deletes the row, returning the storage path.
 * The item disappears from every read immediately (all queries filter
 * `deleted_at IS NULL`) and stops counting toward the case quotas. The row is
 * hard-deleted only after its storage object is confirmed removed
 * (see delete-evidence/index.ts); if removal fails, the soft-deleted row keeps
 * the path so the scheduled purge can retry — an object is never orphaned.
 */
export async function softDeleteEvidence(
  userId: string,
  evidenceId: string,
): Promise<string> {
  const db = turso();
  const found = await db.execute({
    sql: `SELECT storage_path FROM evidence_files
           WHERE id = ? AND user_id = ? AND deleted_at IS NULL`,
    args: [evidenceId, userId],
  });
  if (found.rows.length === 0) {
    throw new ApiError(404, "evidence_not_found", "Evidence not found");
  }
  const path = String(
    (found.rows[0] as unknown as Record<string, unknown>).storage_path,
  );
  await db.execute({
    sql: "UPDATE evidence_files SET deleted_at = ? WHERE id = ? AND user_id = ?",
    args: [new Date().toISOString(), evidenceId, userId],
  });
  return path;
}

/** Removes the row once its storage object is gone (links cascade via FK). */
export async function hardDeleteEvidence(
  userId: string,
  evidenceId: string,
): Promise<void> {
  await turso().execute({
    sql: "DELETE FROM evidence_files WHERE id = ? AND user_id = ?",
    args: [evidenceId, userId],
  });
}

/** Lists a case's evidence metadata (owner only; FR-EVD-05). */
export async function listEvidence(
  caseId: string,
  userId: string,
): Promise<Array<Record<string, unknown>>> {
  const result = await turso().execute({
    sql: `SELECT id, category, title, description, document_date,
                 original_filename, mime_type, size_bytes, sha256_hash, uploaded_at
            FROM evidence_files
           WHERE case_id = ? AND user_id = ? AND deleted_at IS NULL
           ORDER BY uploaded_at DESC`,
    args: [caseId, userId],
  });
  return result.rows.map((r) => {
    const row = r as unknown as Record<string, unknown>;
    return {
      id: row.id,
      category: row.category,
      title: row.title,
      description: row.description,
      document_date: row.document_date,
      original_filename: row.original_filename,
      mime_type: row.mime_type,
      size_bytes: row.size_bytes,
      sha256_hash: row.sha256_hash,
      uploaded_at: row.uploaded_at,
    };
  });
}

/** Returns storage info for an owned evidence file, or throws 404. */
export async function getEvidenceForDownload(
  evidenceId: string,
  userId: string,
): Promise<{ storagePath: string; originalFilename: string; mimeType: string }> {
  const found = await turso().execute({
    sql: `SELECT storage_path, original_filename, mime_type
            FROM evidence_files
           WHERE id = ? AND user_id = ? AND deleted_at IS NULL`,
    args: [evidenceId, userId],
  });
  if (found.rows.length === 0) {
    throw new ApiError(404, "evidence_not_found", "Evidence not found");
  }
  const row = found.rows[0] as unknown as Record<string, unknown>;
  return {
    storagePath: String(row.storage_path),
    originalFilename: String(row.original_filename),
    mimeType: String(row.mime_type),
  };
}
