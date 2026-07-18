// list-evidence — returns the metadata of a case's evidence (owner only,
// FR-EVD-05). Storage paths are not exposed to the client.
import { withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import { readJsonObject } from "../_shared/validation.ts";
import { requireCaseId, requireOwnedCase } from "../_shared/cases.ts";
import { listEvidence } from "../_shared/evidence.ts";

Deno.serve(withAuth(async ({ userId, req }) => {
  const body = await readJsonObject(req);
  const caseId = requireCaseId(body);
  await requireOwnedCase(caseId, userId);
  const evidence = await listEvidence(caseId, userId);
  return jsonResponse({ evidence });
}));
