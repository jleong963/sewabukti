/// MVP storage quotas (§12.2). The app must stop or restrict operations before
/// a free-tier limit is reached (§7.2 no-card rule).
class StorageLimits {
  const StorageLimits._();

  static const int activeCasesPerUser = 1;
  static const int totalEvidenceBytesPerCase = 25 * 1024 * 1024; // 25 MB
  static const int maxPdfBytes = 10 * 1024 * 1024; // 10 MB
  static const int maxImageBytes = 5 * 1024 * 1024; // 5 MB
  static const int maxFilesPerCase = 20;
  static const int projectUploadStopBytes = 800 * 1024 * 1024; // 800 MB
}

/// Application-level email limits, kept well under Gmail's daily sending limits
/// (§17). Failed delivery must never be shown as success (FR-DL-06).
class EmailLimits {
  const EmailLimits._();

  static const int maxPerUserPerDay = 3;
  static const int maxPerAppPerDay = 80;
}

/// Supported evidence upload formats (§12.3). Executables, archives, HTML,
/// scripts, macros, and video are rejected (validated again server-side).
const Set<String> kSupportedEvidenceMimeTypes = {
  'application/pdf',
  'image/jpeg',
  'image/png',
  'image/webp',
  'text/plain',
};

const Set<String> kSupportedEvidenceExtensions = {
  'pdf',
  'jpg',
  'jpeg',
  'png',
  'webp',
  'txt',
};
