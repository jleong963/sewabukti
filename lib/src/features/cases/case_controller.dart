import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sewabukti/src/core/auth/auth_controller.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/features/cases/case_repository.dart';

/// Loads and mutates the signed-in user's single case (FR-CASE-01..03). Rebuilds
/// when auth changes so the case clears on sign-out and reloads on sign-in.
class CaseController extends AsyncNotifier<Case?> {
  @override
  Future<Case?> build() async {
    final AuthState auth = ref.watch(authControllerProvider);
    if (!auth.isSignedIn) return null;
    return ref.read(caseRepositoryProvider).getCurrentCase();
  }

  /// Creates the case if none exists yet (FR-CASE-01).
  Future<Case> createDraft() async {
    final Case created = await ref.read(caseRepositoryProvider).createCase();
    state = AsyncData<Case?>(created);
    return created;
  }

  /// Persists a partial field change (save-per-step, FR-CASE-02/03). Creates the
  /// case first if needed. The claimed amount is recalculated by the store.
  Future<Case> saveFields(Map<String, dynamic> changes) async {
    final CaseRepository repo = ref.read(caseRepositoryProvider);
    Case? current = state.asData?.value;
    current ??= await repo.createCase();
    final Case updated = await repo.updateCase(current.id, changes);
    state = AsyncData<Case?>(updated);
    return updated;
  }

  Future<void> reload() async {
    state = const AsyncLoading<Case?>();
    state = await AsyncValue.guard<Case?>(() async {
      if (!ref.read(authControllerProvider).isSignedIn) return null;
      return ref.read(caseRepositoryProvider).getCurrentCase();
    });
  }

  /// Deletes the current case and its evidence/chronology (FR-CASE-04). The
  /// server removes the associated storage objects and child rows.
  Future<void> deleteCase() async {
    final Case? current = state.asData?.value;
    if (current == null) return;
    await ref.read(caseRepositoryProvider).deleteCase(current.id);
    state = const AsyncData<Case?>(null);
  }
}

final AsyncNotifierProvider<CaseController, Case?> caseControllerProvider =
    AsyncNotifierProvider<CaseController, Case?>(CaseController.new);

/// Rough completion percentage across the four questionnaire sections (§10.2
/// dashboard "current completion percentage").
int caseCompletionPercent(Case? c) {
  if (c == null) return 0;
  const int totalSections = 4;
  int done = 0;
  // The wizard saves unset dates as '' (not null), so emptiness is the check.
  if ((c.propertyLine1?.isNotEmpty ?? false) &&
      (c.tenancyStartDate?.isNotEmpty ?? false)) {
    done++;
  }
  if ((c.claimantFullName?.isNotEmpty ?? false) &&
      (c.claimantEmail?.isNotEmpty ?? false)) {
    done++;
  }
  if ((c.otherPartyName?.isNotEmpty ?? false) && c.otherPartyType != null) {
    done++;
  }
  if (c.totalDepositSenValue > 0) done++;
  return (done * 100 / totalSections).round();
}
