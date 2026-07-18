// Case repository. Ownership is verified for every operation (FR-CASE-05).
// Updates use a column whitelist with parameterised queries (§14.8), and the
// claimed amount is always recalculated server-side (FR-CASE-06).
import { turso } from "./turso.ts";
import { ApiError } from "./handler.ts";
import { decryptSensitive, encryptSensitive } from "./crypto.ts";
import {
  optionalNonNegativeInt,
  optionalString,
  requireString,
} from "./validation.ts";

/// The one field encrypted at rest: the government identity number (§10.3).
const SENSITIVE_COLUMN = "claimant_id_number";

/// Encrypts the identity number (if present) before it is written to Turso.
async function _encryptSensitiveFields(
  fields: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  const value = fields[SENSITIVE_COLUMN];
  if (typeof value !== "string" || value.length === 0) return fields;
  return { ...fields, [SENSITIVE_COLUMN]: await encryptSensitive(value) };
}

/// Decrypts the identity number before returning a case to its authenticated
/// owner. Applied only at client-facing read points.
async function _decryptSensitive(
  caseObj: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  const value = caseObj[SENSITIVE_COLUMN];
  if (typeof value === "string" && value.length > 0) {
    caseObj[SENSITIVE_COLUMN] = await decryptSensitive(value);
  }
  return caseObj;
}

const ALL_COLUMNS = [
  "id",
  "user_id",
  "status",
  "property_line1",
  "property_line2",
  "property_city",
  "property_postcode",
  "property_state",
  "tenancy_start_date",
  "tenancy_end_date",
  "vacated_date",
  "keys_returned_date",
  "refund_deadline_date",
  "monthly_rent_sen",
  "claimant_full_name",
  "claimant_id_number",
  "claimant_email",
  "claimant_phone",
  "claimant_address",
  "other_party_type",
  "other_party_is_company",
  "other_party_name",
  "other_party_company_no",
  "other_party_email",
  "other_party_phone",
  "other_party_address",
  "deposit_received_by",
  "deposit_promised_by",
  "security_deposit_sen",
  "utility_deposit_sen",
  "access_deposit_sen",
  "other_deposit_sen",
  "amount_refunded_sen",
  "deductions_accepted_sen",
  "deductions_disputed_sen",
  "amount_claimed_sen",
  "demand_deadline_date",
  "created_at",
  "updated_at",
] as const;

const TEXT_COLUMNS = new Set<string>([
  "property_line1",
  "property_line2",
  "property_city",
  "property_postcode",
  "property_state",
  "tenancy_start_date",
  "tenancy_end_date",
  "vacated_date",
  "keys_returned_date",
  "refund_deadline_date",
  "claimant_full_name",
  "claimant_id_number",
  "claimant_email",
  "claimant_phone",
  "claimant_address",
  "other_party_name",
  "other_party_company_no",
  "other_party_email",
  "other_party_phone",
  "other_party_address",
  "deposit_received_by",
  "deposit_promised_by",
  "demand_deadline_date",
]);

const INT_COLUMNS = new Set<string>([
  "monthly_rent_sen",
  "security_deposit_sen",
  "utility_deposit_sen",
  "access_deposit_sen",
  "other_deposit_sen",
  "amount_refunded_sen",
  "deductions_accepted_sen",
  "deductions_disputed_sen",
]);

const OTHER_PARTY_TYPES = new Set([
  "landlord",
  "agent",
  "management",
  "uncertain",
]);

type CaseRow = Record<string, unknown>;

function rowToCase(row: CaseRow): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const col of ALL_COLUMNS) out[col] = row[col] ?? null;
  return out;
}

function asInt(value: unknown): number {
  return typeof value === "number" ? value : Number(value ?? 0) || 0;
}

/** Claimed = total deposit − refunded − accepted deductions (never below 0). */
function claimedSen(row: CaseRow): number {
  const total = asInt(row.security_deposit_sen) +
    asInt(row.utility_deposit_sen) +
    asInt(row.access_deposit_sen) +
    asInt(row.other_deposit_sen);
  const claimed = total - asInt(row.amount_refunded_sen) -
    asInt(row.deductions_accepted_sen);
  return claimed > 0 ? claimed : 0;
}

async function selectCaseById(
  caseId: string,
  userId: string,
): Promise<CaseRow | null> {
  const db = turso();
  const result = await db.execute({
    sql: `SELECT ${ALL_COLUMNS.join(", ")}
            FROM cases
           WHERE id = ? AND user_id = ? AND deleted_at IS NULL`,
    args: [caseId, userId],
  });
  if (result.rows.length === 0) return null;
  return result.rows[0] as unknown as CaseRow;
}

/** Confirms the case exists and belongs to the user, or throws 404. */
export async function requireOwnedCase(
  caseId: string,
  userId: string,
): Promise<CaseRow> {
  const row = await selectCaseById(caseId, userId);
  if (!row) throw new ApiError(404, "case_not_found", "Case not found");
  return row;
}

/** Returns a specific owned case (serialized), or null if not found/owned. */
export async function getCaseById(
  userId: string,
  caseId: string,
): Promise<Record<string, unknown> | null> {
  const row = await selectCaseById(caseId, userId);
  return row ? _decryptSensitive(rowToCase(row)) : null;
}

/** Returns the user's current (non-archived) case, or null. */
export async function getCurrentCase(
  userId: string,
): Promise<Record<string, unknown> | null> {
  const db = turso();
  const result = await db.execute({
    sql: `SELECT ${ALL_COLUMNS.join(", ")}
            FROM cases
           WHERE user_id = ? AND status != 'archived' AND deleted_at IS NULL
           ORDER BY created_at DESC
           LIMIT 1`,
    args: [userId],
  });
  if (result.rows.length === 0) return null;
  return _decryptSensitive(rowToCase(result.rows[0] as unknown as CaseRow));
}

/** Creates the user's single active case; 409 if one already exists (§12.2). */
export async function createCase(
  userId: string,
  fields: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  const db = turso();

  const { columns, args } = collectFields(await _encryptSensitiveFields(fields));

  try {
    await db.execute({
      sql: `INSERT INTO cases (id, user_id, status, created_at, updated_at
              ${columns.length ? ", " + columns.join(", ") : ""})
            VALUES (?, ?, 'active', ?, ?
              ${columns.length ? ", " + columns.map(() => "?").join(", ") : ""})`,
      args: [id, userId, now, now, ...args],
    });
  } catch (error) {
    // Unique partial index on active case per user (§12.2).
    const message = String((error as Error)?.message ?? "");
    if (message.includes("UNIQUE") || message.includes("constraint")) {
      throw new ApiError(409, "case_exists", "An active case already exists");
    }
    throw error;
  }

  await recalculateClaim(id, userId);
  return _decryptSensitive(rowToCase(await requireOwnedCase(id, userId)));
}

/** Applies a whitelisted, validated field update and recalculates the claim. */
export async function updateCase(
  userId: string,
  caseId: string,
  fields: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  await requireOwnedCase(caseId, userId);
  const now = new Date().toISOString();
  const { columns, args } = collectFields(
    await _encryptSensitiveFields(fields),
  );

  if (columns.length > 0) {
    const setClause = columns.map((c) => `${c} = ?`).join(", ");
    await turso().execute({
      sql: `UPDATE cases SET ${setClause}, updated_at = ? WHERE id = ? AND user_id = ?`,
      args: [...args, now, caseId, userId],
    });
  }

  await recalculateClaim(caseId, userId);
  return _decryptSensitive(rowToCase(await requireOwnedCase(caseId, userId)));
}

/**
 * Soft-deletes the case (§23.3 retention grace): it is marked `deleted_at` and
 * disappears from every read immediately, but its rows and storage objects are
 * kept until the scheduled purge removes them after the retention window. This
 * allows recovery from accidental deletion within that window.
 */
export async function deleteCase(userId: string, caseId: string): Promise<void> {
  await requireOwnedCase(caseId, userId);
  const now = new Date().toISOString();
  await turso().execute({
    sql: `UPDATE cases
             SET deleted_at = ?, status = 'archived', updated_at = ?
           WHERE id = ? AND user_id = ? AND deleted_at IS NULL`,
    args: [now, now, caseId, userId],
  });
}

async function recalculateClaim(caseId: string, userId: string): Promise<void> {
  const row = await requireOwnedCase(caseId, userId);
  await turso().execute({
    sql: "UPDATE cases SET amount_claimed_sen = ? WHERE id = ? AND user_id = ?",
    args: [claimedSen(row), caseId, userId],
  });
}

/** Validates and collects provided whitelisted fields into columns + args. */
function collectFields(
  fields: Record<string, unknown>,
): { columns: string[]; args: unknown[] } {
  const columns: string[] = [];
  const args: unknown[] = [];

  for (const key of Object.keys(fields)) {
    if (TEXT_COLUMNS.has(key)) {
      const value = optionalString(fields, key);
      if (value !== undefined) {
        columns.push(key);
        args.push(value);
      }
    } else if (INT_COLUMNS.has(key)) {
      const value = optionalNonNegativeInt(fields, key);
      if (value !== undefined) {
        columns.push(key);
        args.push(value);
      }
    } else if (key === "other_party_type") {
      const value = optionalString(fields, key);
      if (value !== undefined) {
        if (!OTHER_PARTY_TYPES.has(value)) {
          throw new ApiError(400, "invalid_field", "Invalid other_party_type");
        }
        columns.push(key);
        args.push(value);
      }
    } else if (key === "other_party_is_company") {
      const raw = fields[key];
      if (raw !== undefined && raw !== null) {
        columns.push(key);
        args.push(raw === true || raw === 1 ? 1 : 0);
      }
    }
    // Unknown keys (including id/user_id/status/amount_claimed_sen) are ignored,
    // so a client cannot set protected columns (FR-AUTH-05).
  }

  return { columns, args };
}

/** Parses a required caseId from a body object. */
export function requireCaseId(body: Record<string, unknown>): string {
  return requireString(body, "case_id", { maxLength: 64 });
}
