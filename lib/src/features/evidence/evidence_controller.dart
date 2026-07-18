import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sewabukti/src/features/cases/case_controller.dart';
import 'package:sewabukti/src/features/evidence/evidence_category.dart';
import 'package:sewabukti/src/features/evidence/evidence_file.dart';
import 'package:sewabukti/src/features/evidence/evidence_repository.dart';

/// Loads and mutates the current case's evidence list. Rebuilds when the case
/// changes (e.g. sign-out clears it).
class EvidenceController extends AsyncNotifier<List<EvidenceFile>> {
  String? _caseId;

  @override
  Future<List<EvidenceFile>> build() async {
    _caseId = ref.watch(caseControllerProvider).asData?.value?.id;
    final String? caseId = _caseId;
    if (caseId == null) return <EvidenceFile>[];
    return ref.read(evidenceRepositoryProvider).list(caseId);
  }

  List<EvidenceFile> get _items => state.asData?.value ?? <EvidenceFile>[];

  int get fileCount => _items.length;
  int get totalBytes =>
      _items.fold(0, (int sum, EvidenceFile e) => sum + e.sizeBytes);

  Future<void> add({
    required EvidenceCategory category,
    required PickedEvidence file,
    String? title,
    String? description,
    String? documentDate,
  }) async {
    final String? caseId = _caseId;
    if (caseId == null) throw const EvidenceException('no_case');
    final EvidenceFile created = await ref
        .read(evidenceRepositoryProvider)
        .upload(
          caseId: caseId,
          category: category,
          file: file,
          title: title,
          description: description,
          documentDate: documentDate,
        );
    state = AsyncData<List<EvidenceFile>>(<EvidenceFile>[created, ..._items]);
  }

  Future<void> remove(EvidenceFile evidence) async {
    await ref.read(evidenceRepositoryProvider).delete(evidence);
    state = AsyncData<List<EvidenceFile>>(
      _items.where((EvidenceFile e) => e.id != evidence.id).toList(),
    );
  }
}

final AsyncNotifierProvider<EvidenceController, List<EvidenceFile>>
evidenceControllerProvider =
    AsyncNotifierProvider<EvidenceController, List<EvidenceFile>>(
      EvidenceController.new,
    );
