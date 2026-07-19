import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sewabukti/src/core/constants/app_limits.dart';
import 'package:sewabukti/src/core/formatting/formatting.dart';
import 'package:sewabukti/src/core/routing/routes.dart';
import 'package:sewabukti/src/core/theme/app_colors.dart';
import 'package:sewabukti/src/features/cases/case_controller.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/features/evidence/evidence_category.dart';
import 'package:sewabukti/src/features/evidence/evidence_controller.dart';
import 'package:sewabukti/src/features/evidence/evidence_file.dart';
import 'package:sewabukti/src/features/evidence/evidence_repository.dart';
import 'package:sewabukti/src/features/shared/widgets/language_selector.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Evidence checklist and management (§10.4). Upload, preview, download, and
/// delete supported files, grouped by the spec's evidence categories.
class CaseEvidencePage extends ConsumerStatefulWidget {
  const CaseEvidencePage({super.key});

  @override
  ConsumerState<CaseEvidencePage> createState() => _CaseEvidencePageState();
}

class _CaseEvidencePageState extends ConsumerState<CaseEvidencePage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Case? currentCase = ref.watch(caseControllerProvider).asData?.value;

    if (currentCase == null) {
      return _scaffold(l10n, _noCase(l10n));
    }

    final AsyncValue<List<EvidenceFile>> evidence = ref.watch(
      evidenceControllerProvider,
    );

    return _scaffold(
      l10n,
      evidence.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.signInFailed)),
        data: (List<EvidenceFile> items) => _body(l10n, items),
      ),
    );
  }

  Widget _scaffold(AppLocalizations l10n, Widget body) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(Routes.dashboard),
      ),
      title: Text(l10n.evidenceTitle),
      actions: const <Widget>[LanguageSelector(compact: true)],
    ),
    body: SafeArea(
      child: Stack(
        children: <Widget>[
          body,
          if (_busy)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    ),
  );

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
          Text(l10n.evidenceNoCaseBody, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(Routes.caseWizard),
            child: Text(l10n.dashboardStartCase),
          ),
        ],
      ),
    ),
  );

  Widget _body(AppLocalizations l10n, List<EvidenceFile> items) {
    final int totalBytes = items.fold(
      0,
      (int s, EvidenceFile e) => s + e.sizeBytes,
    );
    final String usedMb = (totalBytes / (1024 * 1024)).toStringAsFixed(2);
    final String totalMb =
        (StorageLimits.totalEvidenceBytesPerCase / (1024 * 1024))
            .toStringAsFixed(0);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(Icons.storage_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.dashboardStorageValue(usedMb, totalMb),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              l10n.evidenceFileCount(
                                items.length,
                                StorageLimits.maxFilesPerCase,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.evidenceSupportedHint} ${l10n.evidenceHashNote}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (final EvidenceCategory category in EvidenceCategory.values)
                  _CategorySection(
                    category: category,
                    items: items
                        .where((EvidenceFile e) => e.category == category.code)
                        .toList(),
                    busy: _busy,
                    onAdd: () => _addFor(category),
                    onOpen: _open,
                    onDownload: _download,
                    onDelete: _confirmDelete,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _errMessage(String code, AppLocalizations l10n) => switch (code) {
    'unsupported_type' => l10n.errUnsupportedType,
    'file_too_large' => l10n.errFileTooLarge,
    'file_count_exceeded' => l10n.errFileCountExceeded,
    'storage_quota_exceeded' => l10n.errStorageQuota,
    _ => l10n.signInFailed,
  };

  void _snack(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _addFor(EvidenceCategory category) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: kSupportedEvidenceExtensions.toList(),
      );
    } catch (_) {
      _snack(l10n.errPickFailed);
      return;
    }
    if (result == null || result.files.isEmpty) return;

    final PlatformFile f = result.files.first;
    final String? mime = mimeForExtension(f.extension);
    final Uint8List? bytes = f.bytes;
    if (mime == null || bytes == null) {
      _snack(l10n.errUnsupportedType);
      return;
    }
    final PickedEvidence picked = PickedEvidence(
      name: f.name,
      bytes: bytes,
      mimeType: mime,
      sizeBytes: f.size,
    );

    final EvidenceController controller = ref.read(
      evidenceControllerProvider.notifier,
    );
    final String? error = validatePickedEvidence(
      picked,
      currentCount: controller.fileCount,
      currentTotalBytes: controller.totalBytes,
    );
    if (error != null) {
      _snack(_errMessage(error, l10n));
      return;
    }

    if (!mounted) return;
    final _EvidenceDetails? details = await showDialog<_EvidenceDetails>(
      context: context,
      builder: (_) => _EvidenceDetailsDialog(defaultTitle: f.name),
    );
    if (details == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await controller.add(
        category: category,
        file: picked,
        title: details.title,
        description: details.description,
        documentDate: details.documentDate,
      );
      _snack(l10n.evidenceUploaded);
    } catch (e) {
      _snack(_errMessage(e is EvidenceException ? e.code : 'error', l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(EvidenceFile evidence) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final EvidencePreview preview = await ref
          .read(evidenceRepositoryProvider)
          .preview(evidence);
      if (!mounted) return;
      if (preview.isImage && preview.bytes != null) {
        _showImageDialog(Image.memory(preview.bytes!, fit: BoxFit.contain));
      } else if (preview.url != null) {
        if (preview.isImage) {
          _showImageDialog(Image.network(preview.url!, fit: BoxFit.contain));
        } else {
          await launchUrl(Uri.parse(preview.url!), webOnlyWindowName: '_blank');
        }
      } else {
        _snack(l10n.evidencePreviewUnavailable);
      }
    } catch (_) {
      _snack(l10n.evidencePreviewUnavailable);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _download(EvidenceFile evidence) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final String? url = await ref
          .read(evidenceRepositoryProvider)
          .downloadUrl(evidence);
      if (!mounted) return;
      if (url == null) {
        _snack(l10n.evidencePreviewUnavailable);
        return;
      }
      await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
    } catch (_) {
      _snack(l10n.evidencePreviewUnavailable);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete(EvidenceFile evidence) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        content: Text(
          l10n.evidenceDeleteConfirm(
            evidence.title ?? evidence.originalFilename,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonRemove),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(evidenceControllerProvider.notifier).remove(evidence);
    } catch (_) {
      _snack(l10n.signInFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showImageDialog(Widget image) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: InteractiveViewer(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 600),
              child: image,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.items,
    required this.busy,
    required this.onAdd,
    required this.onOpen,
    required this.onDownload,
    required this.onDelete,
  });

  final EvidenceCategory category;
  final List<EvidenceFile> items;
  final bool busy;
  final VoidCallback onAdd;
  final ValueChanged<EvidenceFile> onOpen;
  final ValueChanged<EvidenceFile> onDownload;
  final ValueChanged<EvidenceFile> onDelete;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(category.icon, color: context.sb.deepSeaBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.label(l10n),
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text('${items.length}', style: text.labelLarge),
                  ),
                TextButton.icon(
                  onPressed: busy ? null : onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.evidenceAdd),
                ),
              ],
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(36, 0, 0, 4),
                child: Text(
                  l10n.evidenceEmptyCategory,
                  style: text.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (final EvidenceFile e in items)
                _EvidenceTile(
                  evidence: e,
                  onOpen: () => onOpen(e),
                  onDownload: () => onDownload(e),
                  onDelete: () => onDelete(e),
                ),
          ],
        ),
      ),
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({
    required this.evidence,
    required this.onOpen,
    required this.onDownload,
    required this.onDelete,
  });

  final EvidenceFile evidence;
  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String sizeKb = (evidence.sizeBytes / 1024).toStringAsFixed(0);
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 36, right: 0),
      dense: true,
      leading: Icon(
        evidence.isImage
            ? Icons.image_outlined
            : Icons.insert_drive_file_outlined,
      ),
      title: Text(
        evidence.title?.isNotEmpty == true
            ? evidence.title!
            : evidence.originalFilename,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('${evidence.originalFilename} · $sizeKb KB'),
      trailing: PopupMenuButton<String>(
        onSelected: (String value) {
          switch (value) {
            case 'open':
              onOpen();
            case 'download':
              onDownload();
            case 'delete':
              onDelete();
          }
        },
        itemBuilder: (_) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'open',
            child: Text(l10n.evidencePreview),
          ),
          PopupMenuItem<String>(
            value: 'download',
            child: Text(l10n.evidenceDownload),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Text(l10n.evidenceDelete),
          ),
        ],
      ),
    );
  }
}

class _EvidenceDetails {
  const _EvidenceDetails({this.title, this.description, this.documentDate});
  final String? title;
  final String? description;
  final String? documentDate;
}

class _EvidenceDetailsDialog extends StatefulWidget {
  const _EvidenceDetailsDialog({required this.defaultTitle});
  final String defaultTitle;

  @override
  State<_EvidenceDetailsDialog> createState() => _EvidenceDetailsDialogState();
}

class _EvidenceDetailsDialogState extends State<_EvidenceDetailsDialog> {
  late final TextEditingController _title = TextEditingController(
    text: widget.defaultTitle,
  );
  final TextEditingController _description = TextEditingController();
  String? _documentDate;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = Localizations.localeOf(context);
    return AlertDialog(
      title: Text(l10n.evidenceAddDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: l10n.evidenceItemTitle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.evidenceItemDescription,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final DateTime now = DateTime.now();
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _documentDate != null
                      ? DateTime.tryParse(_documentDate!) ?? now
                      : now,
                  firstDate: DateTime(2010),
                  lastDate: DateTime(now.year + 5),
                );
                if (picked != null) {
                  setState(() => _documentDate = toIsoDate(picked));
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.evidenceItemDate,
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                  ),
                ),
                child: Text(
                  _documentDate == null
                      ? l10n.selectDate
                      : formatIsoDate(_documentDate, locale),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _EvidenceDetails(
              title: _title.text.trim().isEmpty ? null : _title.text.trim(),
              description: _description.text.trim().isEmpty
                  ? null
                  : _description.text.trim(),
              documentDate: _documentDate,
            ),
          ),
          child: Text(l10n.evidenceAdd),
        ),
      ],
    );
  }
}
