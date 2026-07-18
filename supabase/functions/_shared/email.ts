// Transactional email via Gmail SMTP (nodemailer), server-side only
// (FR-DL-05, FR-EML-01). Application-level daily limits are stricter than the
// provider's (§17, FR-EML-04). Failed delivery is never reported as success
// (FR-DL-06).
import nodemailer from "npm:nodemailer@9.0.3";
import { turso } from "./turso.ts";
import { ApiError } from "./handler.ts";

const MAX_PER_USER_PER_DAY = 3;
const MAX_PER_APP_PER_DAY = 80;

/** Throws 429 if sending would exceed the per-user or per-app daily limit. */
export async function assertEmailQuota(userId: string): Promise<void> {
  const db = turso();
  const sinceMidnightUtc = new Date().toISOString().slice(0, 10); // YYYY-MM-DD

  const perUser = await db.execute({
    sql: `SELECT COUNT(*) AS n FROM demand_letters
           WHERE user_id = ? AND sent_at IS NOT NULL AND sent_at >= ?`,
    args: [userId, `${sinceMidnightUtc}T00:00:00.000Z`],
  });
  if (Number((perUser.rows[0] as unknown as Record<string, unknown>).n ?? 0) >= MAX_PER_USER_PER_DAY) {
    throw new ApiError(429, "email_daily_limit", "Daily email limit reached");
  }

  const perApp = await db.execute({
    sql: `SELECT COUNT(*) AS n FROM demand_letters
           WHERE sent_at IS NOT NULL AND sent_at >= ?`,
    args: [`${sinceMidnightUtc}T00:00:00.000Z`],
  });
  if (Number((perApp.rows[0] as unknown as Record<string, unknown>).n ?? 0) >= MAX_PER_APP_PER_DAY) {
    throw new ApiError(429, "email_daily_limit", "Service email limit reached");
  }
}

export interface EmailAttachment {
  filename: string;
  contentBase64: string;
}

export interface SendResult {
  id: string;
}

/** Sends an email through Gmail SMTP; throws on failure (caller records status). */
export async function sendEmail(params: {
  to: string;
  subject: string;
  html: string;
  attachments?: EmailAttachment[];
}): Promise<SendResult> {
  const user = Deno.env.get("GMAIL_USER");
  const pass = Deno.env.get("GMAIL_APP_PASSWORD");
  if (!user || !pass) {
    throw new ApiError(500, "server_misconfigured", "Email not configured");
  }
  // Gmail forces the authenticated mailbox as the sender, so the From address
  // is always this account (a display name is still allowed). Unlike a shared
  // test sender, Gmail delivers to arbitrary recipients — no domain to verify.
  // GMAIL_FROM is optional and only customises the display name.
  const from = Deno.env.get("GMAIL_FROM") ?? `SewaBukti <${user}>`;

  const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true, // implicit TLS
    auth: { user, pass },
  });

  try {
    const info = await transporter.sendMail({
      from,
      to: params.to,
      subject: params.subject,
      html: params.html,
      attachments: params.attachments?.map((a) => ({
        filename: a.filename,
        content: a.contentBase64,
        encoding: "base64",
        contentType: "application/pdf",
      })),
    });
    return { id: info.messageId ?? "" };
  } catch (_error) {
    throw new ApiError(502, "email_send_failed", "Email delivery failed");
  }
}
