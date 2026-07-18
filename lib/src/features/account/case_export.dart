import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/features/chronology/timeline_event.dart';
import 'package:sewabukti/src/features/evidence/evidence_file.dart';

/// Builds the user's case-data export (§10.9 "Download a case data export",
/// FR-EXP data portability). Assembled entirely client-side from data already
/// loaded; nothing is uploaded.
///
/// The raw identity-card/passport number is deliberately omitted (NFR-SEC-10/14)
/// — it is masked in the UI and encrypted at rest, and is not written into a
/// plaintext export the user might store or share unintentionally.
Map<String, dynamic> buildCaseExportJson({
  required Case caseData,
  required List<EvidenceFile> evidence,
  required List<TimelineEvent> timeline,
  required String generatedAt,
}) {
  final Map<String, dynamic> caseJson = caseData.toJson()
    ..remove('claimant_id_number');

  return <String, dynamic>{
    'app': 'SewaBukti',
    'export_generated_at': generatedAt,
    'note':
        'Personal data export. Identity-card/passport numbers are omitted for '
        'your safety.',
    'case': caseJson,
    'evidence': <Map<String, dynamic>>[
      for (final EvidenceFile e in evidence) e.toJson(),
    ],
    'chronology': <Map<String, dynamic>>[
      for (final TimelineEvent t in timeline) t.toJson(),
    ],
  };
}
