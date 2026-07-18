/// Sanitises an original filename before it is displayed or used in a download
/// header (NFR-SEC-07). Strips directory components and control characters,
/// neutralises characters unsafe in paths/headers, collapses whitespace, and
/// bounds the length while preserving a short extension where possible.
String sanitizeFilename(String name, {int maxLength = 128}) {
  String s = name.trim();
  if (s.isEmpty) return 'file';

  // Drop any path components (defeats traversal / header injection via name).
  s = s.split(RegExp(r'[\\/]')).last;

  // Remove control characters (incl. CR/LF and DEL) and neutralise characters
  // that are unsafe in filenames or content-disposition headers.
  s = s.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
  s = s.replaceAll(RegExp(r'["<>:|?*]'), '_');

  // Collapse whitespace and strip leading dots (avoids hidden-file names).
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  s = s.replaceFirst(RegExp(r'^\.+'), '');
  if (s.isEmpty) return 'file';

  if (s.length > maxLength) {
    final int dot = s.lastIndexOf('.');
    if (dot > 0 && s.length - dot <= 10) {
      final String ext = s.substring(dot);
      s = s.substring(0, maxLength - ext.length) + ext;
    } else {
      s = s.substring(0, maxLength);
    }
  }
  return s;
}
