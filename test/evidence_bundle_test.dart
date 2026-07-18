import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:sewabukti/src/features/bundle/evidence_bundle.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/features/chronology/timeline_event.dart';
import 'package:sewabukti/src/features/evidence/evidence_file.dart';
import 'package:sewabukti/src/l10n/app_localizations_en.dart';

EvidenceFile _ev(
  String id,
  String category, {
  String mime = 'application/pdf',
  String? documentDate,
}) => EvidenceFile(
  id: id,
  category: category,
  originalFilename: '$id.bin',
  mimeType: mime,
  sizeBytes: 1234,
  uploadedAt: '2026-07-10T08:00:00.000Z',
  documentDate: documentDate,
);

void main() {
  setUpAll(() async {
    // Bundle dates are formatted with intl's DateFormat (as in the app's main).
    await initializeDateFormatting();
  });

  final AppLocalizationsEn l10n = AppLocalizationsEn();
  const Locale locale = Locale('en');

  final Case caseData = const Case(
    id: 'case-1',
    propertyLine1: '12 Jalan Mawar',
    propertyCity: 'Ipoh',
    claimantFullName: 'Aisyah',
    securityDepositSen: 150000,
    amountRefundedSen: 40000,
  );

  // One file per section, deliberately added out of section order.
  final List<EvidenceFile> evidence = <EvidenceFile>[
    _ev('e-utility', 'utility_bills'),
    _ev('e-tenancy', 'tenancy_agreement'),
    _ev('e-photo', 'movein_photos', mime: 'image/jpeg'),
    _ev('e-deposit', 'deposit_receipt'),
    _ev('e-other', 'other'),
  ];

  EvidenceBundleModel build({
    required Set<String> selected,
    Set<String> embedded = const <String>{},
    List<TimelineEvent> timeline = const <TimelineEvent>[],
    bool includeChronology = true,
  }) => buildEvidenceBundleModel(
    l10n: l10n,
    locale: locale,
    caseData: caseData,
    timeline: timeline,
    evidence: evidence,
    inputs: EvidenceBundleInputs(
      preparedByName: 'Aisyah',
      selectedEvidenceIds: selected,
      includeChronology: includeChronology,
    ),
    embeddedIds: embedded,
    today: '10 July 2026',
  );

  test('appendix ids are assigned in section order across all selected', () {
    final EvidenceBundleModel m = build(
      selected: <String>{'e-utility', 'e-tenancy', 'e-photo', 'e-deposit'},
    );

    // Section order: tenancy(0) → deposit(1) → handover(2) → utility(3).
    final Map<String, String> byId = <String, String>{
      for (final BundleEvidenceEntry e in m.indexEntries)
        e.evidenceId: e.appendixId,
    };
    expect(byId['e-tenancy'], 'SB-A01');
    expect(byId['e-deposit'], 'SB-A02');
    expect(byId['e-photo'], 'SB-A03');
    expect(byId['e-utility'], 'SB-A04');
    expect(m.indexEntries, hasLength(4));
  });

  test('excluded evidence is omitted and remaining items renumber', () {
    // Exclude the tenancy agreement; the rest must renumber from SB-A01.
    final EvidenceBundleModel m = build(
      selected: <String>{'e-deposit', 'e-photo', 'e-utility'},
    );
    final Map<String, String> byId = <String, String>{
      for (final BundleEvidenceEntry e in m.indexEntries)
        e.evidenceId: e.appendixId,
    };
    expect(byId.containsKey('e-tenancy'), isFalse);
    expect(byId.containsKey('e-other'), isFalse);
    expect(byId['e-deposit'], 'SB-A01');
    expect(byId['e-photo'], 'SB-A02');
    expect(byId['e-utility'], 'SB-A03');
    expect(m.indexEntries, hasLength(3));
  });

  test('sections group correctly and only non-empty sections appear', () {
    final EvidenceBundleModel m = build(
      selected: <String>{'e-tenancy', 'e-deposit', 'e-photo', 'e-utility'},
    );
    expect(
      m.sections.map((BundleSection s) => s.kind).toList(),
      <BundleSectionKind>[
        BundleSectionKind.tenancyAgreement,
        BundleSectionKind.depositPayment,
        BundleSectionKind.handoverCondition,
        BundleSectionKind.utility,
      ],
    );
    // No "other"/communications/etc. sections since they have no items.
    expect(
      m.sections.any((BundleSection s) => s.kind == BundleSectionKind.other),
      isFalse,
    );
  });

  test('only images with fetched bytes are marked embedded', () {
    final EvidenceBundleModel m = build(
      selected: <String>{'e-tenancy', 'e-photo'},
      embedded: <String>{'e-photo'},
    );
    final BundleEvidenceEntry photo = m.indexEntries.firstWhere(
      (BundleEvidenceEntry e) => e.evidenceId == 'e-photo',
    );
    final BundleEvidenceEntry tenancy = m.indexEntries.firstWhere(
      (BundleEvidenceEntry e) => e.evidenceId == 'e-tenancy',
    );
    expect(photo.embedded, isTrue);
    expect(tenancy.embedded, isFalse); // PDF is never embedded
  });

  test('chronology cross-references only linked, included evidence', () {
    final EvidenceBundleModel m = build(
      selected: <String>{'e-photo', 'e-deposit'},
      timeline: <TimelineEvent>[
        const TimelineEvent(
          id: 't1',
          eventDate: '2026-05-01',
          title: 'Moved out',
          // e-other is excluded, so it must not appear as a reference.
          evidenceIds: <String>['e-photo', 'e-other'],
        ),
      ],
    );
    expect(m.chronologyRows, hasLength(1));
    // e-photo is SB-A02 here (deposit=SB-A01, photo=SB-A02).
    expect(m.chronologyRows.single.appendixRefs, <String>['SB-A02']);
  });

  test('chronology can be excluded entirely', () {
    final EvidenceBundleModel m = build(
      selected: <String>{'e-photo'},
      includeChronology: false,
      timeline: <TimelineEvent>[
        const TimelineEvent(id: 't1', eventDate: '2026-05-01', title: 'X'),
      ],
    );
    expect(m.chronologyRows, isEmpty);
  });
}
