// get-case — returns a specific owned case, or the user's current case if no
// id is supplied. Ownership is enforced (FR-CASE-05).
import { withAuth } from "../_shared/handler.ts";
import { errorResponse, jsonResponse } from "../_shared/http.ts";
import { getCaseById, getCurrentCase } from "../_shared/cases.ts";

Deno.serve(withAuth(async ({ userId, req }) => {
  let caseId: string | undefined;
  try {
    const body = await req.json();
    if (body && typeof body === "object" && typeof body.case_id === "string") {
      caseId = body.case_id;
    }
  } catch (_error) {
    // No body -> return the current case.
  }

  const result = caseId
    ? await getCaseById(userId, caseId)
    : await getCurrentCase(userId);

  if (!result) return errorResponse(404, "case_not_found", "Case not found");
  return jsonResponse(result);
}));
