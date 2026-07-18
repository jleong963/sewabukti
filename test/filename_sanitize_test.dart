import 'package:flutter_test/flutter_test.dart';

import 'package:sewabukti/src/core/security/filename.dart';

void main() {
  test('strips directory components (path traversal defence)', () {
    expect(sanitizeFilename('a/b/c.pdf'), 'c.pdf');
    expect(sanitizeFilename(r'..\..\evil.txt'), 'evil.txt');
  });

  test('removes control characters', () {
    // NUL (0), unit separator (31), and DEL (127) between letters are stripped.
    final String withControls =
        'a${String.fromCharCode(0)}b${String.fromCharCode(31)}c${String.fromCharCode(127)}.txt';
    expect(sanitizeFilename(withControls), 'abc.txt');
    expect(sanitizeFilename('line\r\nbreak.txt'), 'linebreak.txt');
  });

  test('neutralises characters unsafe in filenames/headers', () {
    expect(sanitizeFilename('a<b>c:d"e|f?g*.txt'), 'a_b_c_d_e_f_g_.txt');
  });

  test('collapses whitespace and strips leading dots', () {
    expect(sanitizeFilename('a   b.txt'), 'a b.txt');
    expect(sanitizeFilename('...hidden'), 'hidden');
  });

  test('empty or whitespace-only names fall back to a safe default', () {
    expect(sanitizeFilename('   '), 'file');
    expect(sanitizeFilename(''), 'file');
  });

  test('bounds length while preserving a short extension', () {
    final String long = '${'a' * 200}.pdf';
    final String out = sanitizeFilename(long, maxLength: 20);
    expect(out.length, 20);
    expect(out.endsWith('.pdf'), isTrue);
  });
}
