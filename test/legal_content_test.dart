import 'package:flutter_test/flutter_test.dart';

import 'package:sewabukti/src/core/constants/legal_config.dart';
import 'package:sewabukti/src/core/legal/legal_content.dart';
import 'package:sewabukti/src/core/preferences/app_language.dart';

String _flatten(InfoDocument d) {
  final StringBuffer b = StringBuffer()
    ..writeln(d.title)
    ..writeln(d.intro ?? '');
  for (final InfoSection s in d.sections) {
    b.writeln(s.heading ?? '');
    b.writeAll(s.paragraphs, '\n');
    b.writeAll(s.bullets, '\n');
  }
  b.writeln(d.footer ?? '');
  return b.toString();
}

void main() {
  for (final AppLanguage lang in AppLanguage.values) {
    test('legal documents are populated for ${lang.code}', () {
      for (final InfoDocument doc in <InfoDocument>[
        privacyPolicyDoc(lang),
        termsOfUseDoc(lang),
        helpDoc(lang),
        claimRouteDoc(lang),
      ]) {
        expect(doc.title.trim(), isNotEmpty);
        expect(doc.sections, isNotEmpty);
      }
    });

    test(
      'claim route states the configurable limit and form (${lang.code})',
      () {
        final String text = _flatten(claimRouteDoc(lang));
        expect(text.contains('RM5,000'), isTrue);
        expect(text.contains('Form 198'), isTrue);
      },
    );

    test('privacy notice names the service providers (${lang.code})', () {
      final String text = _flatten(privacyPolicyDoc(lang));
      // NFR-SEC-13: the notice must explain the providers used.
      expect(text.contains('Supabase'), isTrue);
      expect(text.contains('Google'), isTrue);
      expect(text.contains('Gmail'), isTrue);
    });
  }

  test('help content is not marked as pending legal review', () {
    expect(helpDoc(AppLanguage.en).reviewPending, isFalse);
  });

  test('privacy and terms are flagged for professional legal review', () {
    expect(privacyPolicyDoc(AppLanguage.en).reviewPending, isTrue);
    expect(termsOfUseDoc(AppLanguage.en).reviewPending, isTrue);
  });

  test('privacy policy states the configured retention period (§23.3)', () {
    final String text = _flatten(privacyPolicyDoc(AppLanguage.en));
    expect(text.contains('${LegalConfig.deletionPurgeDays} days'), isTrue);
  });

  test('small-claims ceiling label is formatted with a separator', () {
    expect(smallClaimsCeilingLabel(), 'RM5,000');
  });
}
