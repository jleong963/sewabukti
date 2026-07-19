// Shared request wrapper for protected functions. Centralises the security
// order (§14): CORS/preflight, method check, Google token verification, and
// resolving the internal user id — BEFORE any application logic. Fails closed.
import { handlePreflight } from "./cors.ts";
import { errorResponse } from "./http.ts";
import {
  AuthError,
  bearerToken,
  type GoogleIdentity,
  verifyGoogleIdToken,
} from "./google_auth.ts";
import { resolveUserId } from "./users.ts";

/// A non-auth application error with a stable, non-sensitive code.
export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

export interface AuthContext {
  identity: GoogleIdentity;
  /// Internal SewaBukti user id (never client-supplied; FR-AUTH-05/09).
  userId: string;
  req: Request;
}

export function withAuth(
  handler: (ctx: AuthContext) => Promise<Response>,
  opts: { method?: string } = {},
): (req: Request) => Promise<Response> {
  const method = opts.method ?? "POST";
  return async (req: Request): Promise<Response> => {
    const preflight = handlePreflight(req);
    if (preflight) return preflight;
    if (req.method !== method) {
      return errorResponse(405, "method_not_allowed", `Use ${method}`);
    }
    try {
      const identity = await verifyGoogleIdToken(bearerToken(req));
      const userId = await resolveUserId(identity);
      return await handler({ identity, userId, req });
    } catch (error) {
      if (error instanceof AuthError) {
        const status = error.code === "server_misconfigured" ? 500 : 401;
        // Server-side only: a 5xx here is an ops/config problem worth logging.
        if (status >= 500) {
          console.error("[withAuth] auth misconfig:", error.code, error.message);
        }
        return errorResponse(status, error.code, error.message);
      }
      if (error instanceof ApiError) {
        if (error.status >= 500) {
          console.error("[withAuth] api error:", error.code, error.message);
        }
        return errorResponse(error.status, error.code, error.message);
      }
      // Log the real cause to the function logs so a 500 is diagnosable; the
      // client response never carries internal details or stack traces (§14.10).
      console.error("[withAuth] unexpected error:", error);
      return errorResponse(500, "internal_error", "Unexpected error");
    }
  };
}
