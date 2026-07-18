// create-case — creates the user's single active case (§10.3, FR-CASE-01).
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import { readJsonObject } from "../_shared/validation.ts";
import { createCase } from "../_shared/cases.ts";
import { writeAudit } from "../_shared/audit.ts";

Deno.serve(withAuth(async ({ userId, req }) => {
  // All case fields are optional at creation; tolerate an empty body.
  let body: Record<string, unknown> = {};
  try {
    body = await readJsonObject(req);
  } catch (_error) {
    body = {};
  }

  const created = await createCase(userId, body);
  await writeAudit({
    userId,
    caseId: String(created.id),
    action: "case.create",
    entityType: "case",
    entityId: String(created.id),
  });
  return jsonResponse(created, 201);
}));
