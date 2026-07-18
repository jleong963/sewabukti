import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sewabukti/src/features/cases/case_controller.dart';
import 'package:sewabukti/src/features/chronology/timeline_event.dart';
import 'package:sewabukti/src/features/chronology/timeline_repository.dart';

/// Loads and mutates the current case's chronology (FR-CHR-*). After each
/// mutation the list is reloaded so its order reflects the server/store.
class TimelineController extends AsyncNotifier<List<TimelineEvent>> {
  String? _caseId;

  @override
  Future<List<TimelineEvent>> build() async {
    _caseId = ref.watch(caseControllerProvider).asData?.value?.id;
    final String? caseId = _caseId;
    if (caseId == null) return <TimelineEvent>[];
    return ref.read(timelineRepositoryProvider).list(caseId);
  }

  Future<void> _reload() async {
    final String? caseId = _caseId;
    if (caseId == null) return;
    state = AsyncData<List<TimelineEvent>>(
      await ref.read(timelineRepositoryProvider).list(caseId),
    );
  }

  Future<void> add({
    required String eventDate,
    String? eventTime,
    required String title,
    String? description,
    required List<String> evidenceIds,
  }) async {
    final String? caseId = _caseId;
    if (caseId == null) return;
    await ref
        .read(timelineRepositoryProvider)
        .create(
          caseId,
          eventDate: eventDate,
          eventTime: eventTime,
          title: title,
          description: description,
          evidenceIds: evidenceIds,
        );
    await _reload();
  }

  Future<void> edit(TimelineEvent event) async {
    await ref.read(timelineRepositoryProvider).update(event);
    await _reload();
  }

  Future<void> remove(String eventId) async {
    await ref.read(timelineRepositoryProvider).delete(eventId);
    await _reload();
  }

  Future<void> reorder(List<String> orderedIds) async {
    final String? caseId = _caseId;
    if (caseId == null) return;
    await ref.read(timelineRepositoryProvider).reorder(caseId, orderedIds);
    await _reload();
  }
}

final AsyncNotifierProvider<TimelineController, List<TimelineEvent>>
timelineControllerProvider =
    AsyncNotifierProvider<TimelineController, List<TimelineEvent>>(
      TimelineController.new,
    );
