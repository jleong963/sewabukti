// AES-GCM encryption for sensitive fields at rest (identity numbers, §10.3 /
// NFR-SEC-09/10). Keys are server-only secrets, never exposed to the client.
// Encrypted values are opaque in the database and in any logs.
//
// Key rotation (ready for future use, not yet operated):
//   * Ciphertext is tagged with the KEY ID that wrote it: `v1.<keyId>.<iv>.<ct>`.
//   * Multiple keys are configured via APP_ENCRYPTION_KEYS ("id:base64,id:base64");
//     APP_ENCRYPTION_KEY_ACTIVE_ID selects which one encrypts new data.
//   * Old ciphertext keeps decrypting as long as its key remains in the set, so
//     a new key can be added without a data migration.
//   * A single legacy APP_ENCRYPTION_KEY is still supported (treated as id "1").
// See supabase/functions/README.md "Key rotation" for the runbook.
import { ApiError } from "./handler.ts";

const ALGO = "AES-GCM";
const PREFIX = "v1";

let registry: Map<string, CryptoKey> | null = null;
let activeId: string | null = null;

async function loadRegistry(): Promise<void> {
  if (registry) return;

  // Parse configured keys as [id, base64] pairs.
  const entries: Array<[string, string]> = [];
  const multi = Deno.env.get("APP_ENCRYPTION_KEYS");
  const legacy = Deno.env.get("APP_ENCRYPTION_KEY");

  if (multi && multi.trim().length > 0) {
    for (const part of multi.split(",")) {
      const trimmed = part.trim();
      if (trimmed.length === 0) continue;
      const idx = trimmed.indexOf(":");
      if (idx <= 0) {
        throw new ApiError(
          500,
          "server_misconfigured",
          "Invalid APP_ENCRYPTION_KEYS entry",
        );
      }
      entries.push([trimmed.slice(0, idx).trim(), trimmed.slice(idx + 1).trim()]);
    }
  } else if (legacy && legacy.trim().length > 0) {
    entries.push(["1", legacy.trim()]); // legacy single key -> id "1"
  }

  if (entries.length === 0) {
    throw new ApiError(500, "server_misconfigured", "Encryption key not set");
  }

  const map = new Map<string, CryptoKey>();
  for (const [id, b64] of entries) {
    const raw = _fromBase64(b64);
    if (raw.length !== 32) {
      throw new ApiError(
        500,
        "server_misconfigured",
        `Encryption key '${id}' must be 32 bytes`,
      );
    }
    map.set(
      id,
      await crypto.subtle.importKey("raw", raw, ALGO, false, [
        "encrypt",
        "decrypt",
      ]),
    );
  }

  registry = map;
  const explicit = Deno.env.get("APP_ENCRYPTION_KEY_ACTIVE_ID");
  activeId = explicit && map.has(explicit)
    ? explicit
    : entries[entries.length - 1][0];
}

function keyFor(id: string): CryptoKey {
  const key = registry!.get(id);
  if (!key) {
    throw new ApiError(
      500,
      "server_misconfigured",
      `Unknown encryption key id: ${id}`,
    );
  }
  return key;
}

/// Encrypts with the active key: `v1.<keyId>.<iv>.<ciphertext>` (base64 parts).
export async function encryptSensitive(plain: string): Promise<string> {
  await loadRegistry();
  const id = activeId!;
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const buf = await crypto.subtle.encrypt(
    { name: ALGO, iv },
    keyFor(id),
    new TextEncoder().encode(plain),
  );
  return `${PREFIX}.${id}.${_toBase64(iv)}.${_toBase64(new Uint8Array(buf))}`;
}

/// Decrypts using the key id embedded in the value. Values not in the `v1.`
/// format are returned unchanged (tolerates legacy/plaintext data).
export async function decryptSensitive(stored: string): Promise<string> {
  const parts = stored.split(".");
  if (parts[0] !== PREFIX) return stored;
  await loadRegistry();

  let id: string;
  let ivB64: string;
  let dataB64: string;
  if (parts.length === 4) {
    id = parts[1];
    ivB64 = parts[2];
    dataB64 = parts[3];
  } else if (parts.length === 3) {
    // Legacy format with no key id: assume the earliest key.
    id = registry!.has("1") ? "1" : activeId!;
    ivB64 = parts[1];
    dataB64 = parts[2];
  } else {
    return stored;
  }

  const buf = await crypto.subtle.decrypt(
    { name: ALGO, iv: _fromBase64(ivB64) },
    keyFor(id),
    _fromBase64(dataB64),
  );
  return new TextDecoder().decode(buf);
}

/// Future key rotation: re-encrypts a value under the active key, decrypting it
/// first with whatever key wrote it. Returns the input unchanged if it is not
/// encrypted or is already under the active key. Intended for a maintenance
/// pass after adding a new active key.
export async function reencryptSensitive(stored: string): Promise<string> {
  const parts = stored.split(".");
  if (parts[0] !== PREFIX) return stored;
  await loadRegistry();
  if (parts.length === 4 && parts[1] === activeId) return stored;
  return encryptSensitive(await decryptSensitive(stored));
}

function _toBase64(bytes: Uint8Array): string {
  let s = "";
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s);
}

function _fromBase64(b64: string): Uint8Array {
  const s = atob(b64);
  const out = new Uint8Array(s.length);
  for (let i = 0; i < s.length; i++) out[i] = s.charCodeAt(i);
  return out;
}
