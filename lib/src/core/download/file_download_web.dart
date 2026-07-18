import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Web implementation: builds a Blob from the text content and clicks a
/// temporary anchor to download it, then revokes the object URL. Nothing is
/// uploaded — the file is created and saved entirely in the browser.
void downloadTextFile({
  required String filename,
  required String content,
  String mimeType = 'application/json',
}) {
  final web.Blob blob = web.Blob(
    <JSAny>[content.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final String url = web.URL.createObjectURL(blob);
  final web.HTMLAnchorElement anchor =
      web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..download = filename
        ..style.display = 'none';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
