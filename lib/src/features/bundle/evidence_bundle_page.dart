import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import 'package:sewabukti/src/core/formatting/formatting.dart';
import 'package:sewabukti/src/core/routing/routes.dart';
import 'package:sewabukti/src/features/bundle/evidence_bundle.dart';
import 'package:sewabukti/src/features/cases/case_controller.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/features/chronology/timeline_controller.dart';
import 'package:sewabukti/src/features/chronology/timeline_event.dart';
import 'package:sewabukti/src/features/evidence/evidence_category.dart';
import 'package:sewabukti/src/features/evidence/evidence_controller.dart';
import 'package:sewabukti/src/features/evidence/evidence_file.dart';
import 'package:sewabukti/src/features/evidence/evidence_repository.dart';
import 'package:sewabukti/src/features/shared/widgets/language_selector.dart';
import 'package:sewabukti/src/features/shared/widgets/legal_notice.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Evidence-bundle generator (§10.8, FR-EXP-*). Choose which evidence to
/// include (so sensitive items can be excluded), review a final checklist, then
/// generate an indexed PDF entirely in the browser. Nothing is uploaded.
class EvidenceBundlePage extends ConsumerStatefulWidget {
  const EvidenceBundlePage({super.key});

  @override
  ConsumerState<EvidenceBundlePage> createState() => _EvidenceBundlePageState();
}

class _EvidenceBundlePageState extends ConsumerState<EvidenceBundlePage> {
  final TextEditingController _preparedBy = TextEditingController();
  final Set<String> _deselected = <String>{};
  bool _includeChronology = true;
  bool _confirmed = false;
  bool _busy = false;
  bool _seeded = false;

  @override
  void dispose() {
    _preparedBy.dispose();
    super.dispose();
  }

  void _seed(Case c) {
    if (_seeded) return;
    _seeded = true;
    _preparedBy.text = c.claimantFullName ?? '';
  }

  bool _isSelected(String id) => !_deselected.contains(id);

  List<EvidenceFile> _selectedEvidence(List<EvidenceFile> all) =>
      all.where((EvidenceFile e) => _isSelected(e.id)).toList();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Case? c = ref.watch(caseControllerProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.dashboard),
        ),
        title: Text(l10n.bundleTitle),
        actions: const <Widget>[LanguageSelector(compact: true)],
      ),
      body: SafeArea(
        child: c == null
            ? _noCase(l10n)
            : Stack(
                children: <Widget>[
                  _form(l10n, c),
                  if (_busy)
                    Positioned.fill(
                      child: ColoredBox(
                        color: const Color(0x55000000),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Text(l10n.bundleGenerating),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _noCase(AppLocalizations l10n) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            l10n.evidenceNoCaseTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(l10n.bundleNoCaseBody, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(Routes.caseWizard),
            child: Text(l10n.dashboardStartCase),
          ),
        ],
      ),
    ),
  );

  Widget _form(AppLocalizations l10n, Case c) {
    _seed(c);
    final List<EvidenceFile> evidence =
        ref.watch(evidenceControllerProvider).asData?.value ?? <EvidenceFile>[];
    final List<TimelineEvent> timeline =
        ref.watch(timelineControllerProvider).asData?.value ??
        <TimelineEvent>[];
    final TextTheme text = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(l10n.bundleIntro, style: text.bodyMedium),
                const SizedBox(height: 20),

                // What is always included, plus the chronology toggle.
                Text(l10n.bundleIncludedHeading, style: text.titleSmall),
                const SizedBox(height: 4),
                _bullet(l10n.bundleIncludeCaseSummary),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _includeChronology,
                  onChanged: (bool? v) =>
                      setState(() => _includeChronology = v ?? true),
                  title: Text(l10n.bundleIncludeChronology),
                  subtitle: Text(
                    l10n.bundleChecklistEvents(timeline.length),
                    style: text.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),

                _evidenceSelector(l10n, evidence),
                const SizedBox(height: 16),

                TextField(
                  controller: _preparedBy,
                  decoration: InputDecoration(
                    labelText: l10n.bundlePreparedByLabel,
                  ),
                ),
                const SizedBox(height: 16),

                _checklistCard(l10n, evidence, timeline),
                const SizedBox(height: 8),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _confirmed,
                  onChanged: (bool? v) =>
                      setState(() => _confirmed = v ?? false),
                  title: Text(l10n.bundleConfirmCheckbox),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _generate,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(l10n.bundleGenerate),
                  ),
                ),
                const SizedBox(height: 20),
                const LegalServiceNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bullet(String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Icon(Icons.check_circle_outline, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
      ],
    ),
  );

  Widget _evidenceSelector(AppLocalizations l10n, List<EvidenceFile> evidence) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(l10n.bundleEvidenceHeading, style: text.titleSmall),
            ),
            if (evidence.isNotEmpty) ...<Widget>[
              TextButton(
                onPressed: () => setState(_deselected.clear),
                child: Text(l10n.bundleSelectAll),
              ),
              TextButton(
                onPressed: () => setState(
                  () => _deselected
                    ..clear()
                    ..addAll(evidence.map((EvidenceFile e) => e.id)),
                ),
                child: Text(l10n.bundleSelectNone),
              ),
            ],
          ],
        ),
        if (evidence.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.bundleNoEvidence,
              style: text.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else ...<Widget>[
          Text(
            l10n.bundleEvidenceHint,
            style: text.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          for (final EvidenceFile e in evidence)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              value: _isSelected(e.id),
              onChanged: (bool? v) => setState(() {
                if (v ?? false) {
                  _deselected.remove(e.id);
                } else {
                  _deselected.add(e.id);
                }
              }),
              title: Text(
                (e.title?.trim().isNotEmpty ?? false)
                    ? e.title!.trim()
                    : e.originalFilename,
              ),
              subtitle: Text(
                '${EvidenceCategory.fromCode(e.category).label(l10n)} · '
                '${e.isImage ? l10n.bundleEmbeddedHint : l10n.bundleAttachmentHint}',
                style: text.bodySmall,
              ),
            ),
        ],
      ],
    );
  }

  Widget _checklistCard(
    AppLocalizations l10n,
    List<EvidenceFile> evidence,
    List<TimelineEvent> timeline,
  ) {
    final List<EvidenceFile> selected = _selectedEvidence(evidence);
    final int images = selected.where((EvidenceFile e) => e.isImage).length;
    final int attachments = selected.length - images;
    final TextTheme text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.bundleChecklistHeading,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.bundleChecklistEvidence(selected.length, evidence.length),
            ),
            Text(l10n.bundleChecklistEmbedded(images, attachments)),
            if (_includeChronology)
              Text(l10n.bundleChecklistEvents(timeline.length)),
          ],
        ),
      ),
    );
  }

  void _snack(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _generate() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = Localizations.localeOf(context);
    if (!_confirmed) {
      _snack(l10n.bundleConfirmRequired);
      return;
    }
    final Case? c = ref.read(caseControllerProvider).asData?.value;
    if (c == null) return;

    final List<EvidenceFile> evidence =
        ref.read(evidenceControllerProvider).asData?.value ?? <EvidenceFile>[];
    final List<TimelineEvent> timeline =
        ref.read(timelineControllerProvider).asData?.value ?? <TimelineEvent>[];
    final EvidenceRepository repo = ref.read(evidenceRepositoryProvider);
    final List<EvidenceFile> selected = _selectedEvidence(evidence);

    setState(() => _busy = true);
    try {
      // Prepare image bytes for embedding; non-images and any that cannot be
      // fetched/decoded are listed as separate attachments instead (§10.8).
      final Map<String, Uint8List> images = <String, Uint8List>{};
      for (final EvidenceFile e in selected.where(
        (EvidenceFile e) => e.isImage,
      )) {
        try {
          final Uint8List? raw = await repo.fetchBytes(e);
          if (raw == null) continue;
          final Uint8List? prepared = await embeddableImageBytes(
            raw,
            e.mimeType,
          );
          if (prepared != null) images[e.id] = prepared;
        } catch (_) {
          // Skip this image; it will appear as an attachment entry.
        }
      }

      final EvidenceBundleModel model = buildEvidenceBundleModel(
        l10n: l10n,
        locale: locale,
        caseData: c,
        timeline: timeline,
        evidence: evidence,
        inputs: EvidenceBundleInputs(
          preparedByName: _preparedBy.text.trim(),
          selectedEvidenceIds: selected.map((EvidenceFile e) => e.id).toSet(),
          includeChronology: _includeChronology,
        ),
        embeddedIds: images.keys.toSet(),
        today: formatIsoDate(toIsoDate(DateTime.now()), locale),
      );

      final Uint8List bytes = await renderEvidenceBundlePdf(
        model,
        imagesById: images,
      );
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (_) {
      if (mounted) _snack(l10n.bundleGenerateFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
