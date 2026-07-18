// Selects the web implementation only when compiling for the web (JS or wasm;
// see gis.dart for why `js_interop` — not `html` — is the right condition). VM
// tests and any non-web target use the no-op stub.
import 'file_download_stub.dart'
    if (dart.library.js_interop) 'file_download_web.dart'
    as impl;

/// Triggers a browser download of an in-memory text file (§10.9 "Download a
/// case data export"). Web-only; a no-op on other targets.
void downloadTextFile({
  required String filename,
  required String content,
  String mimeType = 'application/json',
}) => impl.downloadTextFile(
  filename: filename,
  content: content,
  mimeType: mimeType,
);
