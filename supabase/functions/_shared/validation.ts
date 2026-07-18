// Request-body parsing and validation helpers (§14.9). All throw ApiError on
// invalid input so functions can validate size, types, required fields, and
// numeric ranges consistently.
import { ApiError } from "./handler.ts";

/** Parses a JSON object body; throws 400 on non-object or malformed JSON. */
export async function readJsonObject(
  req: Request,
): Promise<Record<string, unknown>> {
  let raw: unknown;
  try {
    raw = await req.json();
  } catch (_error) {
    throw new ApiError(400, "invalid_body", "Body must be JSON");
  }
  if (raw === null || typeof raw !== "object" || Array.isArray(raw)) {
    throw new ApiError(400, "invalid_body", "Body must be a JSON object");
  }
  return raw as Record<string, unknown>;
}

export function requireString(
  obj: Record<string, unknown>,
  key: string,
  { maxLength = 2000 }: { maxLength?: number } = {},
): string {
  const value = obj[key];
  if (typeof value !== "string" || value.length === 0) {
    throw new ApiError(400, "invalid_field", `Missing or invalid: ${key}`);
  }
  if (value.length > maxLength) {
    throw new ApiError(400, "invalid_field", `Too long: ${key}`);
  }
  return value;
}

export function optionalString(
  obj: Record<string, unknown>,
  key: string,
  { maxLength = 2000 }: { maxLength?: number } = {},
): string | undefined {
  const value = obj[key];
  if (value === undefined || value === null) return undefined;
  if (typeof value !== "string") {
    throw new ApiError(400, "invalid_field", `Invalid: ${key}`);
  }
  if (value.length > maxLength) {
    throw new ApiError(400, "invalid_field", `Too long: ${key}`);
  }
  return value;
}

/** Validates a non-negative integer within [0, max]. */
export function optionalNonNegativeInt(
  obj: Record<string, unknown>,
  key: string,
  { max = 1_000_000_000 }: { max?: number } = {},
): number | undefined {
  const value = obj[key];
  if (value === undefined || value === null) return undefined;
  if (typeof value !== "number" || !Number.isInteger(value) || value < 0) {
    throw new ApiError(400, "invalid_field", `Invalid amount: ${key}`);
  }
  if (value > max) {
    throw new ApiError(400, "invalid_field", `Amount too large: ${key}`);
  }
  return value;
}

export function requirePositiveInt(
  obj: Record<string, unknown>,
  key: string,
  { max = 50 * 1024 * 1024 }: { max?: number } = {},
): number {
  const value = obj[key];
  if (typeof value !== "number" || !Number.isInteger(value) || value <= 0) {
    throw new ApiError(400, "invalid_field", `Invalid: ${key}`);
  }
  if (value > max) {
    throw new ApiError(400, "invalid_field", `Too large: ${key}`);
  }
  return value;
}

/** Coerces a JSON field into a list of strings (non-strings dropped). */
export function stringList(
  obj: Record<string, unknown>,
  key: string,
  { maxItems = 100 }: { maxItems?: number } = {},
): string[] {
  const value = obj[key];
  if (!Array.isArray(value)) return <string[]> [];
  return value
    .filter((x): x is string => typeof x === "string")
    .slice(0, maxItems);
}

export function requireEnum(
  obj: Record<string, unknown>,
  key: string,
  allowed: ReadonlySet<string>,
): string {
  const value = requireString(obj, key);
  if (!allowed.has(value)) {
    throw new ApiError(400, "invalid_field", `Invalid value: ${key}`);
  }
  return value;
}
