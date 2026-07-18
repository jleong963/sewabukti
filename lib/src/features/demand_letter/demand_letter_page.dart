import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import 'package:sewabukti/src/core/formatting/formatting.dart';
import 'package:sewabukti/src/core/preferences/app_language.dart';
import 'package:sewabukti/src/core/preferences/preferences_providers.dart';
import 'package:sewabukti/src/core/routing/routes.dart';
import 'package:sewabukti/src/features/cases/case_controller.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/features/demand_letter/demand_letter.dart';
import 'package:sewabukti/src/features/demand_letter/demand_letter_repository.dart';
import 'package:sewabukti/src/features/evidence/evidence_controller.dart';
import 'package:sewabukti/src/features/evidence/evidence_file.dart';
import 'package:sewabukti/src/features/shared/widgets/legal_notice.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Demand-letter generator (§10.6, FR-DL-*). Choose a language, confirm the
/// facts, edit an optional free-text note, then download/print the PDF or send
/// it by email. Nothing is generated until the user confirms accuracy.
class DemandLetterPage extends ConsumerStatefulWidget {
  const DemandLetterPage({super.key});

  @override
  ConsumerState<DemandLetterPage> createState() => _DemandLetterPageState();
}

class _DemandLetterPageState extends ConsumerState<DemandLetterPage> {
  final TextEditingController _recipientEmail = TextEditingController();
  final TextEditingController _signature = TextEditingController();
  final TextEditingController _paymentInstructions = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  AppLanguage? _language;
  String? _deadline;
  bool _confirmed = false;
  bool _busy = false;
  bool _seeded = false;

  @override
  void dispose() {
    _recipientEmail.dispose();
    _signature.dispose();
    _paymentInstructions.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _seed(Case c) {
    if (_seeded) return;
    _seeded = true;
    // The letter is emailed to the tenant themselves (§23.5 decision); they
    // then forward or serve it to the other party. Default to their own email.
    _recipientEmail.text = c.claimantEmail ?? '';
    _signature.text = c.claimantFullName ?? '';
    _language = ref.read(localeControllerProvider.notifier).current;
  }

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
        title: Text(l10n.demandLetterTitle),
      ),
      body: SafeArea(
        child: c == null
            ? _noCase(l10n)
            : Stack(
                children: <Widget>[
                  _form(l10n, c),
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
          Text(l10n.demandNoCaseBody, textAlign: TextAlign.center),
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
    final Locale locale = Localizations.localeOf(context);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.demandLetterIntro,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                Text(
                  l10n.demandLanguageLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<AppLanguage>(
                  segments: <ButtonSegment<AppLanguage>>[
                    for (final AppLanguage lang in AppLanguage.values)
                      ButtonSegment<AppLanguage>(
                        value: lang,
                        label: Text(lang.endonym),
                      ),
                  ],
                  selected: <AppLanguage>{_language ?? AppLanguage.en},
                  onSelectionChanged: (Set<AppLanguage> s) =>
                      setState(() => _language = s.first),
                ),
                const SizedBox(height: 16),

                _factsCard(l10n, c, locale),
                const SizedBox(height: 16),

                TextField(
                  controller: _recipientEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.demandCopyToLabel,
                    helperText: l10n.demandDeliveryNote,
                    helperMaxLines: 3,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _signature,
                  decoration: InputDecoration(
                    labelText: l10n.demandSignatureLabel,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDeadline,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.demandDeadlineLabel,
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                      ),
                    ),
                    child: Text(
                      _deadline == null
                          ? l10n.selectDate
                          : formatIsoDate(_deadline, locale),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _paymentInstructions,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.demandPaymentInstructionsLabel,
                    helperText: l10n.demandPaymentInstructionsHint,
                    helperMaxLines: 3,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notes,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: l10n.demandNotesLabel),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _confirmed,
                  onChanged: (bool? v) =>
                      setState(() => _confirmed = v ?? false),
                  title: Text(l10n.demandConfirmCheckbox),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _downloadPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(l10n.demandDownloadPdf),
                    ),
                    FilledButton.icon(
                      onPressed: _busy ? null : _send,
                      icon: const Icon(Icons.send_outlined),
                      label: Text(l10n.demandSend),
                    ),
                  ],
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

  Widget _factsCard(AppLocalizations l10n, Case c, Locale locale) {
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.demandFactsHeading,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            row(l10n.fieldPartyName, c.otherPartyName ?? l10n.reviewNoData),
            row(
              l10n.labelTotalDeposit,
              formatRmFromSen(c.totalDepositSenValue),
            ),
            row(l10n.fieldAmountRefunded, formatRmFromSen(c.amountRefundedSen)),
            row(
              l10n.fieldDeductionsAccepted,
              formatRmFromSen(c.deductionsAcceptedSen),
            ),
            const Divider(),
            row(
              l10n.labelTotalClaimed,
              formatRmFromSen(c.amountClaimedSenValue),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline != null
          ? DateTime.tryParse(_deadline!) ?? now
          : now.add(const Duration(days: 14)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _deadline = toIsoDate(picked));
  }

  DemandLetterModel? _buildModel() {
    final Case? c = ref.read(caseControllerProvider).asData?.value;
    final AppLanguage lang = _language ?? AppLanguage.en;
    if (c == null || _deadline == null || _signature.text.trim().isEmpty) {
      return null;
    }
    final List<String> docs =
        (ref.read(evidenceControllerProvider).asData?.value ?? <EvidenceFile>[])
            .map(
              (EvidenceFile e) =>
                  e.title?.isNotEmpty == true ? e.title! : e.originalFilename,
            )
            .toList();

    return buildDemandLetterModel(
      l10n: lookupAppLocalizations(lang.locale),
      locale: lang.locale,
      caseData: c,
      today: formatIsoDate(toIsoDate(DateTime.now()), lang.locale),
      inputs: DemandLetterInputs(
        signatureName: _signature.text.trim(),
        paymentDeadline: _deadline!,
        recipientName: c.otherPartyName,
        paymentInstructions: _paymentInstructions.text.trim().isEmpty
            ? null
            : _paymentInstructions.text.trim(),
        freeText: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        supportingDocuments: docs,
      ),
    );
  }

  void _snack(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _downloadPdf() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!_confirmed) {
      _snack(l10n.demandConfirmRequired);
      return;
    }
    final DemandLetterModel? model = _buildModel();
    if (model == null) {
      _snack(l10n.demandMissingFields);
      return;
    }
    setState(() => _busy = true);
    try {
      final bytes = await renderDemandLetterPdf(model);
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (_) {
      _snack(l10n.signInFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!_confirmed) {
      _snack(l10n.demandConfirmRequired);
      return;
    }
    final Case? c = ref.read(caseControllerProvider).asData?.value;
    final DemandLetterModel? model = _buildModel();
    final String recipient = _recipientEmail.text.trim();
    if (c == null || model == null || recipient.isEmpty) {
      _snack(l10n.demandMissingFields);
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(recipient)) {
      _snack(l10n.invalidEmail);
      return;
    }
    final AppLanguage lang = _language ?? AppLanguage.en;

    setState(() => _busy = true);
    try {
      final bytes = await renderDemandLetterPdf(model);
      await ref
          .read(demandLetterRepositoryProvider)
          .send(
            caseId: c.id,
            language: lang.code,
            recipientEmail: recipient,
            subject: model.subject,
            html: renderDemandLetterHtml(model),
            pdfBase64: base64Encode(bytes),
          );
      // Record the accepted payment deadline on the case
      // (`cases.demand_deadline_date`, schema §13.2 "selected by tenant"); the
      // dashboard derives the letter's Sent status from it. Best-effort — the
      // letter is already delivered.
      try {
        await ref.read(caseControllerProvider.notifier).saveFields(
          <String, dynamic>{'demand_deadline_date': _deadline},
        );
      } catch (_) {
        // Non-fatal: the send succeeded; the field can be saved on a retry.
      }
      _snack(l10n.demandSent);
    } on DemandLetterException catch (e) {
      _snack(
        e.code == 'backend_required'
            ? l10n.demandBackendRequired
            : l10n.demandSendFailed,
      );
    } catch (_) {
      _snack(l10n.demandSendFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
