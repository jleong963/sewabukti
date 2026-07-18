import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sewabukti/src/core/formatting/formatting.dart';
import 'package:sewabukti/src/core/routing/routes.dart';
import 'package:sewabukti/src/features/cases/case_controller.dart';
import 'package:sewabukti/src/features/chronology/timeline_controller.dart';
import 'package:sewabukti/src/features/chronology/timeline_event.dart';
import 'package:sewabukti/src/features/evidence/evidence_controller.dart';
import 'package:sewabukti/src/features/evidence/evidence_file.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Chronology builder (§10.5, FR-CHR-*). Add, edit, reorder, and delete factual
/// timeline events, optionally linking evidence. Nothing is inferred.
class CaseChronologyPage extends ConsumerStatefulWidget {
  const CaseChronologyPage({super.key});

  @override
  ConsumerState<CaseChronologyPage> createState() => _CaseChronologyPageState();
}

class _CaseChronologyPageState extends ConsumerState<CaseChronologyPage> {
  bool _busy = false;

  List<String> _suggestions(AppLocalizations l10n) => <String>[
    l10n.evtTenancyCommenced,
    l10n.evtDepositPaid,
    l10n.evtNoticeGiven,
    l10n.evtVacated,
    l10n.evtKeysReturned,
    l10n.evtInspection,
    l10n.evtRefundRequested,
    l10n.evtRefundPromised,
    l10n.evtPartialRefund,
    l10n.evtDeductionDisputed,
    l10n.evtDemandSent,
    l10n.evtDeadlineExpired,
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool hasCase =
        ref.watch(caseControllerProvider).asData?.value != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.dashboard),
        ),
        title: Text(l10n.chronologyTitle),
        actions: <Widget>[
          if (hasCase)
            IconButton(
              tooltip: l10n.chronologySortByDate,
              icon: const Icon(Icons.sort),
              onPressed: _busy ? null : _sortByDate,
            ),
        ],
      ),
      floatingActionButton: hasCase
          ? FloatingActionButton.extended(
              onPressed: _busy ? null : () => _openDialog(null),
              icon: const Icon(Icons.add),
              label: Text(l10n.chronologyAdd),
            )
          : null,
      body: SafeArea(
        child: !hasCase
            ? _noCase(l10n)
            : ref
                  .watch(timelineControllerProvider)
                  .when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => Center(child: Text(l10n.signInFailed)),
                    data: (List<TimelineEvent> events) => _list(l10n, events),
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
          Text(l10n.chronologyNoCaseBody, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(Routes.caseWizard),
            child: Text(l10n.dashboardStartCase),
          ),
        ],
      ),
    ),
  );

  Widget _list(AppLocalizations l10n, List<TimelineEvent> events) {
    final Locale locale = Localizations.localeOf(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.chronologyIntro,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (events.isEmpty)
          Expanded(child: Center(child: Text(l10n.chronologyEmpty)))
        else
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
              itemCount: events.length,
              onReorderItem: (int oldIndex, int newIndex) =>
                  _onReorder(events, oldIndex, newIndex),
              itemBuilder: (BuildContext context, int index) {
                final TimelineEvent e = events[index];
                return _EventTile(
                  key: ValueKey<String>(e.id),
                  event: e,
                  locale: locale,
                  onTap: () => _openDialog(e),
                );
              },
            ),
          ),
      ],
    );
  }

  void _onReorder(List<TimelineEvent> events, int oldIndex, int newIndex) {
    final List<String> ids = events.map((TimelineEvent e) => e.id).toList();
    final String moved = ids.removeAt(oldIndex);
    ids.insert(newIndex, moved);
    _run(() => ref.read(timelineControllerProvider.notifier).reorder(ids));
  }

  void _sortByDate() {
    final List<TimelineEvent> events =
        ref.read(timelineControllerProvider).asData?.value ?? <TimelineEvent>[];
    final List<TimelineEvent> sorted = List<TimelineEvent>.of(events)
      ..sort(
        (TimelineEvent a, TimelineEvent b) =>
            a.eventDate.compareTo(b.eventDate),
      );
    _run(
      () => ref
          .read(timelineControllerProvider.notifier)
          .reorder(sorted.map((TimelineEvent e) => e.id).toList()),
    );
  }

  Future<void> _openDialog(TimelineEvent? existing) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<EvidenceFile> evidence =
        ref.read(evidenceControllerProvider).asData?.value ?? <EvidenceFile>[];

    final _EventResult? result = await showDialog<_EventResult>(
      context: context,
      builder: (_) => _EventDialog(
        existing: existing,
        evidence: evidence,
        suggestions: _suggestions(l10n),
      ),
    );
    if (result == null || !mounted) return;

    final TimelineController controller = ref.read(
      timelineControllerProvider.notifier,
    );
    if (result.delete && existing != null) {
      await _run(() => controller.remove(existing.id));
      return;
    }
    if (existing == null) {
      await _run(
        () => controller.add(
          eventDate: result.eventDate,
          eventTime: result.eventTime,
          title: result.title,
          description: result.description,
          evidenceIds: result.evidenceIds,
        ),
      );
    } else {
      await _run(
        () => controller.edit(
          existing.copyWith(
            eventDate: result.eventDate,
            eventTime: result.eventTime,
            title: result.title,
            description: result.description,
            evidenceIds: result.evidenceIds,
          ),
        ),
      );
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).signInFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required super.key,
    required this.event,
    required this.locale,
    required this.onTap,
  });

  final TimelineEvent event;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String date = formatIsoDate(event.eventDate, locale);
    final String subtitle = <String>[
      if (event.eventTime != null && event.eventTime!.isNotEmpty)
        event.eventTime!,
      if (event.description != null && event.description!.isNotEmpty)
        event.description!,
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          <String>[
            date,
            if (subtitle.isNotEmpty) subtitle,
            if (event.evidenceIds.isNotEmpty)
              l10n.eventLinkedCount(event.evidenceIds.length),
          ].join('\n'),
        ),
        isThreeLine: subtitle.isNotEmpty || event.evidenceIds.isNotEmpty,
        trailing: const Icon(Icons.drag_handle),
      ),
    );
  }
}

class _EventResult {
  const _EventResult({
    required this.eventDate,
    required this.title,
    this.eventTime,
    this.description,
    this.evidenceIds = const <String>[],
    this.delete = false,
  });

  final String eventDate;
  final String? eventTime;
  final String title;
  final String? description;
  final List<String> evidenceIds;
  final bool delete;
}

class _EventDialog extends StatefulWidget {
  const _EventDialog({
    required this.existing,
    required this.evidence,
    required this.suggestions,
  });

  final TimelineEvent? existing;
  final List<EvidenceFile> evidence;
  final List<String> suggestions;

  @override
  State<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<_EventDialog> {
  late final TextEditingController _title = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.existing?.description ?? '',
  );
  late String? _date = widget.existing?.eventDate;
  late String? _time = widget.existing?.eventTime;
  late final Set<String> _selectedEvidence = <String>{
    ...?widget.existing?.evidenceIds,
  };
  String? _error;

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
    final bool editing = widget.existing != null;

    return AlertDialog(
      title: Text(editing ? l10n.chronologyEditEvent : l10n.chronologyAdd),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _pickerField(
                      label: l10n.eventDateLabel,
                      value: _date == null
                          ? null
                          : formatIsoDate(_date, locale),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pickerField(
                      label: l10n.eventTimeLabel,
                      value: _time,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                decoration: InputDecoration(labelText: l10n.eventTitleLabel),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.eventSuggestionsLabel,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  for (final String s in widget.suggestions)
                    ActionChip(
                      label: Text(s),
                      onPressed: () => setState(() => _title.text = s),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _description,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.eventDescriptionLabel,
                ),
              ),
              if (widget.evidence.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  l10n.eventLinkedEvidence,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: <Widget>[
                    for (final EvidenceFile e in widget.evidence)
                      FilterChip(
                        label: Text(
                          e.title?.isNotEmpty == true
                              ? e.title!
                              : e.originalFilename,
                        ),
                        selected: _selectedEvidence.contains(e.id),
                        onSelected: (bool on) => setState(() {
                          if (on) {
                            _selectedEvidence.add(e.id);
                          } else {
                            _selectedEvidence.remove(e.id);
                          }
                        }),
                      ),
                  ],
                ),
              ],
              if (_error != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        if (editing)
          TextButton(
            onPressed: _confirmDelete,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.evidenceDelete),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(editing ? l10n.wizardSaveExit : l10n.chronologyAdd),
        ),
      ],
    );
  }

  Widget _pickerField({
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value ?? l10n.selectDate),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date != null ? DateTime.tryParse(_date!) ?? now : now,
      firstDate: DateTime(2010),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _date = toIsoDate(picked));
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(
        () => _time =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
      );
    }
  }

  void _confirmDelete() {
    Navigator.pop(
      context,
      _EventResult(eventDate: _date ?? '', title: _title.text, delete: true),
    );
  }

  void _submit() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (_date == null || _title.text.trim().isEmpty) {
      setState(() => _error = l10n.fieldRequired);
      return;
    }
    Navigator.pop(
      context,
      _EventResult(
        eventDate: _date!,
        eventTime: _time,
        title: _title.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        evidenceIds: _selectedEvidence.toList(),
      ),
    );
  }
}
