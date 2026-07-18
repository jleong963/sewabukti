import 'package:flutter_test/flutter_test.dart';

import 'package:sewabukti/src/features/account/case_export.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/features/chronology/timeline_event.dart';
import 'package:sewabukti/src/features/evidence/evidence_file.dart';

void main() {
  test('case export omits the raw identity number but keeps other data', () {
    const Case c = Case(
      id: 'case-1',
      claimantFullName: 'Aisyah',
      claimantIdNumber: '900101-01-1234',
      securityDepositSen: 150000,
    );
    final List<EvidenceFile> evidence = <EvidenceFile>[
      const EvidenceFile(
        id: 'e1',
        category: 'tenancy_agreement',
        originalFilename: 'lease.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 100,
        uploadedAt: '2026-07-10T08:00:00.000Z',
      ),
    ];
    final List<TimelineEvent> timeline = <TimelineEvent>[
      const TimelineEvent(id: 't1', eventDate: '2026-05-01', title: 'Vacated'),
    ];

    final Map<String, dynamic> out = buildCaseExportJson(
      caseData: c,
      evidence: evidence,
      timeline: timeline,
      generatedAt: '2026-07-17T00:00:00.000Z',
    );

    final Map<String, dynamic> caseJson = out['case'] as Map<String, dynamic>;
    // Sensitive field must never appear in a plaintext export (NFR-SEC-10/14).
    expect(caseJson.containsKey('claimant_id_number'), isFalse);
    // Non-sensitive data is retained.
    expect(caseJson['claimant_full_name'], 'Aisyah');
    expect((out['evidence'] as List<dynamic>), hasLength(1));
    expect((out['chronology'] as List<dynamic>), hasLength(1));
    expect(out['export_generated_at'], '2026-07-17T00:00:00.000Z');
    expect(out['note'], isNotNull);
  });
}
