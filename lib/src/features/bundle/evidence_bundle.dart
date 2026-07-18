import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:sewabukti/src/core/formatting/formatting.dart';
import 'package:sewabukti/src/core/security/filename.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/features/chronology/timeline_event.dart';
import 'package:sewabukti/src/features/evidence/evidence_category.dart';
import 'package:sewabukti/src/features/evidence/evidence_file.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// The eight evidence sections of the bundle (§10.8 items 8–15). The sixteen
/// upload categories (§10.4) are grouped into these for a readable bundle.
enum BundleSectionKind {
  tenancyAgreement,
  depositPayment,
  handoverCondition,
  utility,
  communications,
  deductionExpense,
  demandDelivery,
  other,
}

/// Maps an upload category to the bundle section it appears under.
BundleSectionKind bundleSectionForCategory(EvidenceCategory c) => switch (c) {
  EvidenceCategory.tenancyAgreement ||
  EvidenceCategory.stampedAgreement => BundleSectionKind.tenancyAgreement,
  EvidenceCategory.depositReceipt => BundleSectionKind.depositPayment,
  EvidenceCategory.moveInPhotos ||
  EvidenceCategory.moveOutPhotos ||
  EvidenceCategory.handoverKeys ||
  EvidenceCategory.inspectionReport => BundleSectionKind.handoverCondition,
  EvidenceCategory.utilityBills => BundleSectionKind.utility,
  EvidenceCategory.messages ||
  EvidenceCategory.emails ||
  EvidenceCategory.priorRequests => BundleSectionKind.communications,
  EvidenceCategory.deductionStatement ||
  EvidenceCategory.repairQuote ||
  EvidenceCategory.repairReceipt => BundleSectionKind.deductionExpense,
  EvidenceCategory.demandDelivery => BundleSectionKind.demandDelivery,
  EvidenceCategory.other => BundleSectionKind.other,
};

String bundleSectionTitle(BundleSectionKind k, AppLocalizations l10n) =>
    switch (k) {
      BundleSectionKind.tenancyAgreement => l10n.bundleSecTenancy,
      BundleSectionKind.depositPayment => l10n.bundleSecDeposit,
      BundleSectionKind.handoverCondition => l10n.bundleSecHandover,
      BundleSectionKind.utility => l10n.bundleSecUtility,
      BundleSectionKind.communications => l10n.bundleSecComms,
      BundleSectionKind.deductionExpense => l10n.bundleSecDeduction,
      BundleSectionKind.demandDelivery => l10n.bundleSecDemand,
      BundleSectionKind.other => l10n.bundleSecOther,
    };

/// Appendix identifier such as `SB-A01` (§10.8, FR-EXP-04).
String bundleAppendixId(int n) => 'SB-A${n.toString().padLeft(2, '0')}';

/// User-controlled choices for the bundle: which evidence to include (so
/// sensitive items can be excluded, §10.8), whether to include the chronology,
/// and the name of the person assembling it.
class EvidenceBundleInputs {
  const EvidenceBundleInputs({
    required this.preparedByName,
    required this.selectedEvidenceIds,
    this.includeChronology = true,
  });

  final String preparedByName;
  final Set<String> selectedEvidenceIds;
  final bool includeChronology;
}

/// One evidence item placed in the bundle, with its assigned appendix id.
class BundleEvidenceEntry {
  const BundleEvidenceEntry({
    required this.evidenceId,
    required this.appendixId,
    required this.label,
    required this.fileName,
    required this.categoryLabel,
    required this.sectionKind,
    required this.mimeType,
    required this.sizeLabel,
    required this.documentDateLabel,
    required this.uploadedDateLabel,
    required this.embedded,
    this.sha256Short,
  });

  final String evidenceId;
  final String appendixId;
  final String label;
  final String fileName;
  final String categoryLabel;
  final BundleSectionKind sectionKind;
  final String mimeType;
  final String sizeLabel;
  final String documentDateLabel; // '' when none — original doc/event date
  final String uploadedDateLabel; // upload date (kept separate, §10.8)
  final bool embedded; // true only for images whose bytes were fetched
  final String? sha256Short;
}

/// A non-empty bundle section with its ordered entries.
class BundleSection {
  const BundleSection({
    required this.kind,
    required this.title,
    required this.entries,
  });

  final BundleSectionKind kind;
  final String title;
  final List<BundleEvidenceEntry> entries;
}

/// One chronology row, with the appendix ids of any linked, included evidence.
class BundleTimelineRow {
  const BundleTimelineRow({
    required this.dateLabel,
    required this.title,
    required this.appendixRefs,
    this.description,
  });

  final String dateLabel;
  final String title;
  final String? description;
  final List<String> appendixRefs;
}

/// Fully assembled, localised bundle content. Holds only strings and structured
/// rows so it is pure and unit-testable; image bytes are supplied separately to
/// the renderer.
class EvidenceBundleModel {
  const EvidenceBundleModel({
    required this.appName,
    required this.bundleTitle,
    required this.coverCaseLine,
    required this.preparedByLabel,
    required this.preparedByName,
    required this.generatedOnLabel,
    required this.generatedOn,
    required this.coverClaimLabel,
    required this.coverClaimAmount,
    required this.disclaimerHeading,
    required this.disclaimerParagraphs,
    required this.provenanceNote,
    required this.caseSummaryHeading,
    required this.caseSummaryRows,
    required this.partiesHeading,
    required this.propertyHeading,
    required this.propertyRows,
    required this.claimantHeading,
    required this.claimantRows,
    required this.otherPartyHeading,
    required this.otherPartyRows,
    required this.depositHeading,
    required this.depositRows,
    required this.claimTotalLabel,
    required this.claimTotalValue,
    required this.chronologyHeading,
    required this.chronologyRows,
    required this.chronologyEmptyText,
    required this.chronologyRefsLabel,
    required this.indexHeading,
    required this.indexIntro,
    required this.indexColumnHeaders,
    required this.indexEntries,
    required this.embeddedTypeLabel,
    required this.attachmentTypeLabel,
    required this.appendixHeading,
    required this.sections,
    required this.attachmentNotice,
    required this.imageUnavailableNotice,
    required this.noEvidenceText,
    required this.metaDocDateLabel,
    required this.metaUploadedLabel,
    required this.metaFileLabel,
    required this.metaHashLabel,
    required this.emptyValue,
    required this.footerDisclaimer,
  });

  final String appName;
  final String bundleTitle;
  final String coverCaseLine;
  final String preparedByLabel;
  final String preparedByName;
  final String generatedOnLabel;
  final String generatedOn;
  final String coverClaimLabel;
  final String coverClaimAmount;

  final String disclaimerHeading;
  final List<String> disclaimerParagraphs;
  final String provenanceNote;

  final String caseSummaryHeading;
  final List<({String label, String value})> caseSummaryRows;

  final String partiesHeading;
  final String propertyHeading;
  final List<({String label, String value})> propertyRows;
  final String claimantHeading;
  final List<({String label, String value})> claimantRows;
  final String otherPartyHeading;
  final List<({String label, String value})> otherPartyRows;

  final String depositHeading;
  final List<({String label, String value})> depositRows;
  final String claimTotalLabel;
  final String claimTotalValue;

  final String chronologyHeading;
  final List<BundleTimelineRow> chronologyRows;
  final String chronologyEmptyText;
  final String chronologyRefsLabel;

  final String indexHeading;
  final String indexIntro;
  final List<String> indexColumnHeaders;
  final List<BundleEvidenceEntry> indexEntries;
  final String embeddedTypeLabel;
  final String attachmentTypeLabel;

  final String appendixHeading;
  final List<BundleSection> sections;
  final String attachmentNotice;
  final String imageUnavailableNotice;
  final String noEvidenceText;

  final String metaDocDateLabel;
  final String metaUploadedLabel;
  final String metaFileLabel;
  final String metaHashLabel;
  final String emptyValue;
  final String footerDisclaimer;
}

String _propertyAddress(Case c) {
  final List<String> parts = <String>[
    if ((c.propertyLine1 ?? '').isNotEmpty) c.propertyLine1!,
    if ((c.propertyLine2 ?? '').isNotEmpty) c.propertyLine2!,
    if ((c.propertyCity ?? '').isNotEmpty) c.propertyCity!,
    if ((c.propertyPostcode ?? '').isNotEmpty) c.propertyPostcode!,
    if ((c.propertyState ?? '').isNotEmpty) c.propertyState!,
  ];
  return parts.join(', ');
}

String _partyTypeLabel(OtherPartyType? t, AppLocalizations l10n) => switch (t) {
  OtherPartyType.landlord => l10n.partyTypeLandlord,
  OtherPartyType.agent => l10n.partyTypeAgent,
  OtherPartyType.management => l10n.partyTypeManagement,
  OtherPartyType.uncertain => l10n.partyTypeUncertain,
  null => '',
};

String _formatBytes(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '$bytes B';
}

/// Builds the bundle content from confirmed case data, the chronology, and the
/// user-selected evidence (FR-EXP-03/05). [embeddedIds] are the evidence ids
/// whose image bytes were successfully prepared, so the index can state
/// truthfully which items are embedded and which are separate attachments.
EvidenceBundleModel buildEvidenceBundleModel({
  required AppLocalizations l10n,
  required ui.Locale locale,
  required Case caseData,
  required List<TimelineEvent> timeline,
  required List<EvidenceFile> evidence,
  required EvidenceBundleInputs inputs,
  required Set<String> embeddedIds,
  required String today,
}) {
  final Case c = caseData;

  // 1) Deterministic order for appendix numbering: by section, then category,
  //    then original document/upload date, then id.
  int secIndex(EvidenceFile e) =>
      bundleSectionForCategory(EvidenceCategory.fromCode(e.category)).index;
  int catIndex(EvidenceFile e) => EvidenceCategory.fromCode(e.category).index;
  String dateKey(EvidenceFile e) =>
      (e.documentDate?.isNotEmpty ?? false) ? e.documentDate! : e.uploadedAt;

  final List<EvidenceFile> selected =
      evidence
          .where((EvidenceFile e) => inputs.selectedEvidenceIds.contains(e.id))
          .toList()
        ..sort((EvidenceFile a, EvidenceFile b) {
          final int s = secIndex(a).compareTo(secIndex(b));
          if (s != 0) return s;
          final int cat = catIndex(a).compareTo(catIndex(b));
          if (cat != 0) return cat;
          final int d = dateKey(a).compareTo(dateKey(b));
          if (d != 0) return d;
          return a.id.compareTo(b.id);
        });

  // 2) Assign appendix ids in that order and build entries.
  final List<BundleEvidenceEntry> entries = <BundleEvidenceEntry>[];
  final Map<String, String> appendixByEvidenceId = <String, String>{};
  for (int i = 0; i < selected.length; i++) {
    final EvidenceFile e = selected[i];
    final String appendixId = bundleAppendixId(i + 1);
    appendixByEvidenceId[e.id] = appendixId;
    final EvidenceCategory cat = EvidenceCategory.fromCode(e.category);
    final String? hash = e.sha256Hash;
    entries.add(
      BundleEvidenceEntry(
        evidenceId: e.id,
        appendixId: appendixId,
        label: (e.title?.trim().isNotEmpty ?? false)
            ? e.title!.trim()
            : sanitizeFilename(e.originalFilename),
        fileName: sanitizeFilename(e.originalFilename),
        categoryLabel: cat.label(l10n),
        sectionKind: bundleSectionForCategory(cat),
        mimeType: e.mimeType,
        sizeLabel: _formatBytes(e.sizeBytes),
        documentDateLabel: formatIsoDate(e.documentDate, locale),
        uploadedDateLabel: formatIsoDate(e.uploadedAt, locale),
        embedded: embeddedIds.contains(e.id),
        sha256Short: (hash != null && hash.length >= 12)
            ? hash.substring(0, 12)
            : hash,
      ),
    );
  }

  // 3) Group into non-empty sections, in section order.
  final List<BundleSection> sections = <BundleSection>[];
  for (final BundleSectionKind k in BundleSectionKind.values) {
    final List<BundleEvidenceEntry> group = entries
        .where((BundleEvidenceEntry e) => e.sectionKind == k)
        .toList();
    if (group.isNotEmpty) {
      sections.add(
        BundleSection(
          kind: k,
          title: bundleSectionTitle(k, l10n),
          entries: group,
        ),
      );
    }
  }

  // 4) Chronology rows, cross-referencing linked evidence by appendix id.
  final List<BundleTimelineRow> chronRows = <BundleTimelineRow>[];
  if (inputs.includeChronology) {
    for (final TimelineEvent ev in timeline) {
      final List<String> refs =
          ev.evidenceIds
              .map((String id) => appendixByEvidenceId[id])
              .whereType<String>()
              .toList()
            ..sort();
      final String time = (ev.eventTime?.isNotEmpty ?? false)
          ? ' ${ev.eventTime}'
          : '';
      chronRows.add(
        BundleTimelineRow(
          dateLabel: '${formatIsoDate(ev.eventDate, locale)}$time',
          title: ev.title,
          description: (ev.description?.trim().isNotEmpty ?? false)
              ? ev.description!.trim()
              : null,
          appendixRefs: refs,
        ),
      );
    }
  }

  // 5) Summary / parties / deposit rows (empty values are skipped).
  List<({String label, String value})> rows() =>
      <({String label, String value})>[];
  void add(
    List<({String label, String value})> list,
    String label,
    String? value,
  ) {
    if (value != null && value.trim().isNotEmpty) {
      list.add((label: label, value: value.trim()));
    }
  }

  void money(
    List<({String label, String value})> list,
    String label,
    int sen, {
    bool always = false,
  }) {
    if (always || sen > 0) {
      list.add((label: label, value: formatRmFromSen(sen)));
    }
  }

  final List<({String label, String value})> summary = rows();
  summary.add((
    label: l10n.labelTotalClaimed,
    value: formatRmFromSen(c.amountClaimedSenValue),
  ));
  if ((c.tenancyStartDate ?? '').isNotEmpty ||
      (c.tenancyEndDate ?? '').isNotEmpty) {
    add(
      summary,
      l10n.bundleTenancyPeriodLabel,
      '${formatIsoDate(c.tenancyStartDate, locale)} – '
              '${formatIsoDate(c.tenancyEndDate, locale)}'
          .trim(),
    );
  }
  add(summary, l10n.fieldVacatedDate, formatIsoDate(c.vacatedDate, locale));
  add(
    summary,
    l10n.fieldKeysReturned,
    formatIsoDate(c.keysReturnedDate, locale),
  );
  add(
    summary,
    l10n.fieldRefundDeadline,
    formatIsoDate(c.refundDeadlineDate, locale),
  );
  summary.add((
    label: l10n.bundleEvidenceCountLabel,
    value: '${entries.length}',
  ));
  summary.add((
    label: l10n.bundleEventCountLabel,
    value: '${chronRows.length}',
  ));

  final List<({String label, String value})> property = rows();
  add(property, l10n.bundlePropertyLabel, _propertyAddress(c));

  final List<({String label, String value})> claimant = rows();
  add(claimant, l10n.fieldFullName, c.claimantFullName);
  add(claimant, l10n.fieldEmail, c.claimantEmail);
  add(claimant, l10n.fieldPhone, c.claimantPhone);
  add(claimant, l10n.fieldCorrespondenceAddress, c.claimantAddress);

  final List<({String label, String value})> otherParty = rows();
  add(otherParty, l10n.fieldPartyType, _partyTypeLabel(c.otherPartyType, l10n));
  add(otherParty, l10n.fieldPartyName, c.otherPartyName);
  if (c.otherPartyIsCompany) {
    add(otherParty, l10n.fieldPartyCompanyNo, c.otherPartyCompanyNo);
  }
  add(otherParty, l10n.fieldPartyEmail, c.otherPartyEmail);
  add(otherParty, l10n.fieldPartyPhone, c.otherPartyPhone);
  add(otherParty, l10n.fieldPartyAddress, c.otherPartyAddress);
  add(otherParty, l10n.fieldDepositReceivedBy, c.depositReceivedBy);
  add(otherParty, l10n.fieldDepositPromisedBy, c.depositPromisedBy);

  final List<({String label, String value})> deposit = rows();
  money(deposit, l10n.fieldSecurityDeposit, c.securityDepositSen);
  money(deposit, l10n.fieldUtilityDeposit, c.utilityDepositSen);
  money(deposit, l10n.fieldAccessDeposit, c.accessDepositSen);
  money(deposit, l10n.fieldOtherDeposit, c.otherDepositSen);
  money(deposit, l10n.labelTotalDeposit, c.totalDepositSenValue, always: true);
  money(deposit, l10n.fieldAmountRefunded, c.amountRefundedSen);
  money(deposit, l10n.fieldDeductionsAccepted, c.deductionsAcceptedSen);
  money(deposit, l10n.fieldDeductionsDisputed, c.deductionsDisputedSen);

  final String propertyLine = _propertyAddress(c);

  return EvidenceBundleModel(
    appName: l10n.appName,
    bundleTitle: l10n.bundleTitle,
    coverCaseLine: propertyLine.isNotEmpty
        ? propertyLine
        : (c.claimantFullName ?? l10n.appName),
    preparedByLabel: l10n.bundleCoverPreparedBy,
    preparedByName: inputs.preparedByName.trim().isNotEmpty
        ? inputs.preparedByName.trim()
        : (c.claimantFullName ?? '—'),
    generatedOnLabel: l10n.bundleGeneratedOn,
    generatedOn: today,
    coverClaimLabel: l10n.labelTotalClaimed,
    coverClaimAmount: formatRmFromSen(c.amountClaimedSenValue),
    disclaimerHeading: l10n.bundleDisclaimerHeading,
    disclaimerParagraphs: <String>[
      l10n.bundleDisclaimerP1,
      l10n.bundleDisclaimerP2,
      l10n.bundleDisclaimerP3,
    ],
    provenanceNote: l10n.bundleProvenanceNote,
    caseSummaryHeading: l10n.bundleCaseSummaryHeading,
    caseSummaryRows: summary,
    partiesHeading: l10n.bundlePartiesHeading,
    propertyHeading: l10n.bundlePropertyHeading,
    propertyRows: property,
    claimantHeading: l10n.bundleClaimantHeading,
    claimantRows: claimant,
    otherPartyHeading: l10n.bundleOtherPartyHeading,
    otherPartyRows: otherParty,
    depositHeading: l10n.bundleDepositHeading,
    depositRows: deposit,
    claimTotalLabel: l10n.labelTotalClaimed,
    claimTotalValue: formatRmFromSen(c.amountClaimedSenValue),
    chronologyHeading: l10n.bundleChronologyHeading,
    chronologyRows: chronRows,
    chronologyEmptyText: l10n.bundleChronologyEmpty,
    chronologyRefsLabel: l10n.bundleChronologyRefsLabel,
    indexHeading: l10n.bundleIndexHeading,
    indexIntro: l10n.bundleIndexIntro(entries.length),
    indexColumnHeaders: <String>[
      l10n.bundleColAppendix,
      l10n.bundleColItem,
      l10n.bundleColCategory,
      l10n.bundleColDocDate,
      l10n.bundleColUploaded,
      l10n.bundleColType,
    ],
    indexEntries: entries,
    embeddedTypeLabel: l10n.bundleEmbeddedType,
    attachmentTypeLabel: l10n.bundleAttachmentType,
    appendixHeading: l10n.bundleEvidenceMainHeading,
    sections: sections,
    attachmentNotice: l10n.bundleAttachmentNotice,
    imageUnavailableNotice: l10n.bundleImageUnavailable,
    noEvidenceText: l10n.bundleNoEvidence,
    metaDocDateLabel: l10n.bundleColDocDate,
    metaUploadedLabel: l10n.bundleColUploaded,
    metaFileLabel: l10n.bundleFileLabel,
    metaHashLabel: l10n.bundleSha256Label,
    emptyValue: '—',
    footerDisclaimer: l10n.bundleFooterDisclaimer,
  );
}

/// Prepares raw image [bytes] for embedding: keeps JPEG/PNG within size as-is,
/// and decodes anything else (e.g. WebP) or downsizes oversized images to a
/// capped-dimension PNG. Returns null when the bytes cannot be decoded. This
/// keeps peak browser memory and PDF size bounded (Phase 5 large-file handling).
Future<Uint8List?> embeddableImageBytes(
  Uint8List bytes,
  String mimeType,
) async {
  const int maxDim = 1600;
  final bool passthroughFormat =
      mimeType == 'image/jpeg' || mimeType == 'image/png';
  try {
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image image = frame.image;
    final int w = image.width;
    final int h = image.height;
    final int longest = w > h ? w : h;

    if (passthroughFormat && longest <= maxDim) {
      image.dispose();
      codec.dispose();
      return bytes; // already embeddable and reasonably sized
    }

    final double scale = longest > maxDim ? maxDim / longest : 1.0;
    final int tw = (w * scale).round().clamp(1, maxDim);
    final int th = (h * scale).round().clamp(1, maxDim);

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
      ui.Rect.fromLTWH(0, 0, tw.toDouble(), th.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
    final ui.Picture picture = recorder.endRecording();
    final ui.Image scaled = await picture.toImage(tw, th);
    final ByteData? png = await scaled.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    codec.dispose();
    picture.dispose();
    scaled.dispose();
    return png?.buffer.asUint8List();
  } catch (_) {
    // If decoding fails, fall back to raw bytes only when the format is one the
    // PDF library can embed directly; otherwise signal "not embeddable".
    return passthroughFormat ? bytes : null;
  }
}

/// Renders the bundle to a downloadable PDF entirely in the browser (§10.8,
/// FR-EXP-01). [imagesById] holds prepared image bytes keyed by evidence id.
Future<Uint8List> renderEvidenceBundlePdf(
  EvidenceBundleModel m, {
  required Map<String, Uint8List> imagesById,
}) async {
  final pw.Font base = await PdfGoogleFonts.notoSansRegular();
  final pw.Font bold = await PdfGoogleFonts.notoSansBold();
  final pw.Font italic = await PdfGoogleFonts.notoSansItalic();
  final pw.Font cjk = await PdfGoogleFonts.notoSansSCRegular();
  final pw.ThemeData theme = pw.ThemeData.withFont(
    base: base,
    bold: bold,
    italic: italic,
    fontFallback: <pw.Font>[cjk],
  );

  const PdfColor grey = PdfColors.grey700;

  pw.Widget heading(String t) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 4, bottom: 8),
    child: pw.Text(
      t,
      style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
    ),
  );

  pw.Widget subHeading(String t) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
    child: pw.Text(
      t,
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
    ),
  );

  pw.Widget kv(({String label, String value}) r, {bool boldValue = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                r.label,
                style: const pw.TextStyle(fontSize: 10, color: grey),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              flex: 3,
              child: pw.Text(
                r.value,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: boldValue
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );

  pw.Widget notice(String text) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
    ),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 10, color: grey)),
  );

  pw.Widget entryWidget(BundleEvidenceEntry e) {
    final Uint8List? imageBytes = e.embedded ? imagesById[e.evidenceId] : null;
    final List<String> meta = <String>[
      e.categoryLabel,
      if (e.documentDateLabel.isNotEmpty)
        '${m.metaDocDateLabel}: ${e.documentDateLabel}',
      '${m.metaUploadedLabel}: ${e.uploadedDateLabel}',
      e.sizeLabel,
    ];
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 12, bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            '${e.appendixId} — ${e.label}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            meta.join('   •   '),
            style: const pw.TextStyle(fontSize: 9, color: grey),
          ),
          if (e.fileName != e.label)
            pw.Text(
              '${m.metaFileLabel}: ${e.fileName}',
              style: const pw.TextStyle(fontSize: 9, color: grey),
            ),
          if (e.sha256Short != null)
            pw.Text(
              '${m.metaHashLabel}: ${e.sha256Short}…',
              style: const pw.TextStyle(fontSize: 9, color: grey),
            ),
          pw.SizedBox(height: 6),
          if (imageBytes != null)
            pw.Container(
              height: 460,
              alignment: pw.Alignment.center,
              child: pw.Image(
                pw.MemoryImage(imageBytes),
                fit: pw.BoxFit.contain,
              ),
            )
          else
            notice(e.embedded ? m.imageUnavailableNotice : m.attachmentNotice),
        ],
      ),
    );
  }

  final pw.Document doc = pw.Document();

  // Cover page (§10.8 item 1) — unnumbered.
  doc.addPage(
    pw.Page(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(48),
      build: (pw.Context ctx) => pw.Center(
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: <pw.Widget>[
            pw.Text(
              m.appName,
              style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(m.bundleTitle, style: const pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 32),
            pw.Text(
              m.coverCaseLine,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 12, color: grey),
            ),
            pw.SizedBox(height: 28),
            pw.Text(m.coverClaimLabel, style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 2),
            pw.Text(
              m.coverClaimAmount,
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 40),
            pw.Text('${m.preparedByLabel}: ${m.preparedByName}'),
            pw.SizedBox(height: 4),
            pw.Text('${m.generatedOnLabel}: ${m.generatedOn}'),
          ],
        ),
      ),
    ),
  );

  // Body (§10.8 items 2–15) with continuous page numbers.
  doc.addPage(
    pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      footer: (pw.Context ctx) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 12),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            pw.Text(
              m.appName,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
            pw.Text(
              '${ctx.pageNumber} / ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ],
        ),
      ),
      build: (pw.Context ctx) => <pw.Widget>[
        // Item 2 — disclaimer & confirmation.
        heading(m.disclaimerHeading),
        for (final String p in m.disclaimerParagraphs) ...<pw.Widget>[
          pw.Text(p, style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 6),
        ],
        pw.SizedBox(height: 6),
        pw.Divider(),
        pw.Text(
          m.provenanceNote,
          style: pw.TextStyle(
            fontSize: 9,
            color: grey,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
        pw.NewPage(),

        // Item 3 — case summary.
        heading(m.caseSummaryHeading),
        for (final ({String label, String value}) r in m.caseSummaryRows) kv(r),
        pw.SizedBox(height: 14),

        // Item 4 — parties and property.
        heading(m.partiesHeading),
        if (m.propertyRows.isNotEmpty) ...<pw.Widget>[
          subHeading(m.propertyHeading),
          for (final ({String label, String value}) r in m.propertyRows) kv(r),
        ],
        if (m.claimantRows.isNotEmpty) ...<pw.Widget>[
          subHeading(m.claimantHeading),
          for (final ({String label, String value}) r in m.claimantRows) kv(r),
        ],
        if (m.otherPartyRows.isNotEmpty) ...<pw.Widget>[
          subHeading(m.otherPartyHeading),
          for (final ({String label, String value}) r in m.otherPartyRows)
            kv(r),
        ],
        pw.SizedBox(height: 14),

        // Item 5 — deposit calculation.
        heading(m.depositHeading),
        for (final ({String label, String value}) r in m.depositRows) kv(r),
        pw.Divider(),
        kv((
          label: m.claimTotalLabel,
          value: m.claimTotalValue,
        ), boldValue: true),
        pw.NewPage(),

        // Item 6 — chronology.
        heading(m.chronologyHeading),
        if (m.chronologyRows.isEmpty)
          pw.Text(
            m.chronologyEmptyText,
            style: const pw.TextStyle(fontSize: 11, color: grey),
          )
        else
          for (final BundleTimelineRow r in m.chronologyRows)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.SizedBox(
                        width: 110,
                        child: pw.Text(
                          r.dateLabel,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(
                          r.title,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  if (r.description != null)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 118, top: 2),
                      child: pw.Text(
                        r.description!,
                        style: const pw.TextStyle(fontSize: 10, color: grey),
                      ),
                    ),
                  if (r.appendixRefs.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 118, top: 2),
                      child: pw.Text(
                        '${m.chronologyRefsLabel}: ${r.appendixRefs.join(', ')}',
                        style: const pw.TextStyle(fontSize: 9, color: grey),
                      ),
                    ),
                ],
              ),
            ),
        pw.NewPage(),

        // Item 7 — evidence index.
        heading(m.indexHeading),
        pw.Text(
          m.indexIntro,
          style: const pw.TextStyle(fontSize: 10, color: grey),
        ),
        pw.SizedBox(height: 8),
        if (m.indexEntries.isEmpty)
          pw.Text(
            m.noEvidenceText,
            style: const pw.TextStyle(fontSize: 11, color: grey),
          )
        else
          pw.TableHelper.fromTextArray(
            headers: m.indexColumnHeaders,
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            columnWidths: <int, pw.TableColumnWidth>{
              0: const pw.FixedColumnWidth(46),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2.4),
              3: const pw.FixedColumnWidth(64),
              4: const pw.FixedColumnWidth(64),
              5: const pw.FixedColumnWidth(58),
            },
            data: <List<String>>[
              for (final BundleEvidenceEntry e in m.indexEntries)
                <String>[
                  e.appendixId,
                  e.label,
                  e.categoryLabel,
                  e.documentDateLabel.isEmpty
                      ? m.emptyValue
                      : e.documentDateLabel,
                  e.uploadedDateLabel,
                  e.embedded ? m.embeddedTypeLabel : m.attachmentTypeLabel,
                ],
            ],
          ),

        // Items 8–15 — the evidence itself, grouped by section.
        pw.NewPage(),
        heading(m.appendixHeading),
        if (m.sections.isEmpty)
          pw.Text(
            m.noEvidenceText,
            style: const pw.TextStyle(fontSize: 11, color: grey),
          )
        else
          for (final BundleSection s in m.sections) ...<pw.Widget>[
            subHeading(s.title),
            for (final BundleEvidenceEntry e in s.entries) entryWidget(e),
          ],

        pw.SizedBox(height: 20),
        pw.Divider(),
        pw.Text(
          m.footerDisclaimer,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ],
    ),
  );

  return doc.save();
}
