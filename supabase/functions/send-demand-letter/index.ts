// send-demand-letter — records a demand-letter version and delivers it via
// Gmail SMTP (server-side only, FR-DL-04/05). Enforces daily email limits (§17)
// and never reports a failed send as success (FR-DL-06). The letter content and
// any PDF are produced client-side and passed in.
import { ApiError, withAuth } from "../_shared/handler.ts";
import { jsonResponse } from "../_shared/http.ts";
import {
  optionalString,
  readJsonObject,
  requireEnum,
  requireString,
} from "../_shared/validation.ts";
import { requireCaseId, requireOwnedCase } from "../_shared/cases.ts";
import { turso } from "../_shared/turso.ts";
import { assertEmailQuota, sendEmail } from "../_shared/email.ts";
import { writeAudit } from "../_shared/audit.ts";

const LANGUAGES = new Set(["en", "ms", "zh-Hans"]);

// Light shape check (not full RFC 5322): rejects obvious garbage before a
// demand-letter row is written and the email is sent (FR-DL-06).
const EMAIL_SHAPE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

Deno.serve(withAuth(async ({ userId, req }) => {
  const body = await readJsonObject(req);
  const caseId = requireCaseId(body);
  await requireOwnedCase(caseId, userId);

  const language = requireEnum(body, "language", LANGUAGES);
  const recipient = requireString(body, "recipient_email", { maxLength: 320 });
  if (!EMAIL_SHAPE.test(recipient)) {
    throw new ApiError(400, "invalid_field", "Invalid recipient_email");
  }
  const subject = requireString(body, "subject", { maxLength: 300 });
  const html = requireString(body, "letter_html", { maxLength: 200000 });
  const pdfBase64 = optionalString(body, "pdf_base64", { maxLength: 15000000 });

  await assertEmailQuota(userId);

  const db = turso();
  const versionResult = await db.execute({
    sql: `SELECT COALESCE(MAX(version), 0) + 1 AS v
            FROM demand_letters WHERE case_id = ? AND user_id = ?`,
    args: [caseId, userId],
  });
  const version = Number(
    (versionResult.rows[0] as unknown as Record<string, unknown>).v ?? 1,
  );

  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  await db.execute({
    sql: `INSERT INTO demand_letters
            (id, case_id, user_id, language, version, letter_content,
             generated_at, recipient_email, delivery_status)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'queued')`,
    args: [id, caseId, userId, language, version, html, now, recipient],
  });

  try {
    const result = await sendEmail({
      to: recipient,
      subject,
      html,
      attachments: pdfBase64 != null
        ? [{ filename: "demand-letter.pdf", contentBase64: pdfBase64 }]
        : undefined,
    });
    await db.execute({
      sql: `UPDATE demand_letters
               SET delivery_status = 'sent', provider_message_id = ?, sent_at = ?
             WHERE id = ?`,
      args: [result.id, new Date().toISOString(), id],
    });
    await writeAudit({
      userId,
      caseId,
      action: "demand_letter.send",
      entityType: "demand_letter",
      entityId: id,
      metadata: { version },
    });
    return jsonResponse({
      id,
      version,
      delivery_status: "sent",
      provider_message_id: result.id,
    });
  } catch (error) {
    await db.execute({
      sql: "UPDATE demand_letters SET delivery_status = 'failed' WHERE id = ?",
      args: [id],
    });
    if (error instanceof ApiError) throw error;
    throw new ApiError(502, "email_send_failed", "Email delivery failed");
  }
}));
