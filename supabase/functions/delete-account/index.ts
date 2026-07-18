// delete-account — soft-deletes the account (NFR-SEC-12/15, §23.3). The user's
// data disappears from the app immediately (every query filters
// `deleted_at IS NULL`, and their Google subject is tombstoned so a fresh
// sign-in does not collide). Rows and storage objects are kept until the
// scheduled `purge-deleted` job removes them after the retention window.
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import { softDeleteAccount } from "../_shared/users.ts";
import { writeAudit } from "../_shared/audit.ts";

Deno.serve(withAuth(async ({ userId }) => {
  // Audit before the row is tombstoned (its FK target still exists).
  await writeAudit({
    userId,
    action: "account.delete",
    entityType: "user",
    entityId: userId,
  });

  await softDeleteAccount(userId);

  return jsonResponse({ deleted: true });
}));
