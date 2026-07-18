import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:sewabukti/src/core/formatting/formatting.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// User-supplied values for the demand letter (§10.6). Facts and amounts come
/// from the confirmed case; these are the extra, user-controlled parts.
class DemandLetterInputs {
  const DemandLetterInputs({
    required this.signatureName,
    required this.paymentDeadline,
    this.recipientName,
    this.paymentInstructions,
    this.freeText,
    this.supportingDocuments = const <String>[],
  });

  final String signatureName;
  final String paymentDeadline; // ISO yyyy-MM-dd
  final String? recipientName;
  final String? paymentInstructions;
  final String? freeText;
  final List<String> supportingDocuments;
}

/// Assembled, localised letter content — rendered identically to PDF and HTML.
class DemandLetterModel {
  DemandLetterModel({
    required this.subject,
    required this.date,
    required this.greeting,
    required this.openingParagraphs,
    required this.depositHeading,
    required this.depositRows,
    required this.outstandingSentence,
    required this.deadlineSentence,
    required this.furtherAction,
    required this.closing,
    required this.signatureName,
    required this.footerDisclaimer,
    this.factsHeading,
    this.factsText,
    this.paymentHeading,
    this.paymentText,
    this.docsHeading,
    this.documents = const <String>[],
  });

  final String subject;
  final String date;
  final String greeting;
  final List<String> openingParagraphs;
  final String depositHeading;
  final List<({String label, String value})> depositRows;
  final String outstandingSentence;
  final String deadlineSentence;
  final String furtherAction;
  final String closing;
  final String signatureName;
  final String footerDisclaimer;
  final String? factsHeading;
  final String? factsText;
  final String? paymentHeading;
  final String? paymentText;
  final String? docsHeading;
  final List<String> documents;
}

String _propertyAddress(Case c) {
  final List<String> parts = <String>[
    if ((c.propertyLine1 ?? '').isNotEmpty) c.propertyLine1!,
    if ((c.propertyLine2 ?? '').isNotEmpty) c.propertyLine2!,
    if ((c.propertyCity ?? '').isNotEmpty) c.propertyCity!,
    if ((c.propertyPostcode ?? '').isNotEmpty) c.propertyPostcode!,
    if ((c.propertyState ?? '').isNotEmpty) c.propertyState!,
  ];
  return parts.isEmpty ? '—' : parts.join(', ');
}

/// Builds the letter content in [locale] (via a looked-up [AppLocalizations]),
/// using only confirmed case data plus the user inputs (FR-DL-01).
DemandLetterModel buildDemandLetterModel({
  required AppLocalizations l10n,
  required Locale locale,
  required Case caseData,
  required DemandLetterInputs inputs,
  required String today,
}) {
  final Case c = caseData;

  final List<({String label, String value})> rows =
      <({String label, String value})>[];
  void row(String label, int sen) {
    if (sen > 0) rows.add((label: label, value: formatRmFromSen(sen)));
  }

  row(l10n.fieldSecurityDeposit, c.securityDepositSen);
  row(l10n.fieldUtilityDeposit, c.utilityDepositSen);
  row(l10n.fieldAccessDeposit, c.accessDepositSen);
  row(l10n.fieldOtherDeposit, c.otherDepositSen);
  rows.add((
    label: l10n.labelTotalDeposit,
    value: formatRmFromSen(c.totalDepositSenValue),
  ));
  row(l10n.fieldAmountRefunded, c.amountRefundedSen);
  row(l10n.fieldDeductionsAccepted, c.deductionsAcceptedSen);

  final List<String> opening = <String>[
    l10n.letterOpening(_propertyAddress(c)),
    if ((c.tenancyStartDate ?? '').isNotEmpty &&
        (c.tenancyEndDate ?? '').isNotEmpty)
      l10n.letterTenancyPeriod(
        formatIsoDate(c.tenancyStartDate, locale),
        formatIsoDate(c.tenancyEndDate, locale),
      ),
  ];

  final bool hasFacts = (inputs.freeText ?? '').trim().isNotEmpty;
  final bool hasPayment = (inputs.paymentInstructions ?? '').trim().isNotEmpty;

  return DemandLetterModel(
    subject: l10n.letterSubject,
    date: today,
    greeting: (inputs.recipientName ?? '').trim().isNotEmpty
        ? l10n.letterGreeting(inputs.recipientName!.trim())
        : l10n.letterGreetingFallback,
    openingParagraphs: opening,
    depositHeading: l10n.letterDepositHeading,
    depositRows: rows,
    outstandingSentence: l10n.letterOutstandingSentence(
      formatRmFromSen(c.amountClaimedSenValue),
    ),
    factsHeading: hasFacts ? l10n.letterFactsHeading : null,
    factsText: hasFacts ? inputs.freeText!.trim() : null,
    deadlineSentence: l10n.letterDeadlineSentence(
      formatIsoDate(inputs.paymentDeadline, locale),
    ),
    paymentHeading: hasPayment ? l10n.letterPaymentHeading : null,
    paymentText: hasPayment ? inputs.paymentInstructions!.trim() : null,
    docsHeading: inputs.supportingDocuments.isEmpty
        ? null
        : l10n.letterDocsHeading,
    documents: inputs.supportingDocuments,
    furtherAction: l10n.letterFurtherAction,
    closing: l10n.letterClosing,
    signatureName: inputs.signatureName.trim(),
    footerDisclaimer: l10n.letterFooterDisclaimer,
  );
}

String _esc(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// HTML rendering used for the demand-letter email body.
String renderDemandLetterHtml(DemandLetterModel m) {
  final StringBuffer b = StringBuffer()
    ..write(
      '<div style="font-family:Arial,Helvetica,sans-serif;'
      'font-size:14px;line-height:1.5;color:#172b33;">',
    )
    ..write('<p>${_esc(m.date)}</p>')
    ..write('<p>${_esc(m.greeting)}</p>');
  for (final String p in m.openingParagraphs) {
    b.write('<p>${_esc(p)}</p>');
  }
  b.write('<h4>${_esc(m.depositHeading)}</h4><table cellpadding="4">');
  for (final ({String label, String value}) r in m.depositRows) {
    b.write(
      '<tr><td>${_esc(r.label)}</td>'
      '<td style="text-align:right">${_esc(r.value)}</td></tr>',
    );
  }
  b.write('</table>');
  b.write('<p><strong>${_esc(m.outstandingSentence)}</strong></p>');
  if (m.factsText != null) {
    b.write('<h4>${_esc(m.factsHeading!)}</h4><p>${_esc(m.factsText!)}</p>');
  }
  b.write('<p>${_esc(m.deadlineSentence)}</p>');
  if (m.paymentText != null) {
    b.write(
      '<h4>${_esc(m.paymentHeading!)}</h4><p>${_esc(m.paymentText!)}</p>',
    );
  }
  if (m.documents.isNotEmpty) {
    b.write('<h4>${_esc(m.docsHeading!)}</h4><ul>');
    for (final String d in m.documents) {
      b.write('<li>${_esc(d)}</li>');
    }
    b.write('</ul>');
  }
  b.write('<p>${_esc(m.furtherAction)}</p>');
  b.write('<p>${_esc(m.closing)}</p>');
  b.write('<p>${_esc(m.signatureName)}</p>');
  b.write(
    '<hr><p style="font-size:12px;color:#52666d">'
    '${_esc(m.footerDisclaimer)}</p>',
  );
  b.write('</div>');
  return b.toString();
}

/// Client-side PDF generation (§10.6 #6, FR-EXP-01). Uses Noto Sans with a
/// Noto Sans SC fallback so English, Malay, and Chinese letters all render.
Future<Uint8List> renderDemandLetterPdf(DemandLetterModel m) async {
  final pw.Font base = await PdfGoogleFonts.notoSansRegular();
  final pw.Font bold = await PdfGoogleFonts.notoSansBold();
  final pw.Font cjk = await PdfGoogleFonts.notoSansSCRegular();
  final pw.ThemeData theme = pw.ThemeData.withFont(
    base: base,
    bold: bold,
    fontFallback: <pw.Font>[cjk],
  );

  final pw.Document doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      footer: (pw.Context ctx) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 12),
        child: pw.Text(
          'Page ${ctx.pageNumber} / ${ctx.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ),
      build: (pw.Context ctx) => <pw.Widget>[
        pw.Text(m.date),
        pw.SizedBox(height: 16),
        pw.Text(m.greeting),
        pw.SizedBox(height: 8),
        for (final String p in m.openingParagraphs) ...<pw.Widget>[
          pw.Text(p),
          pw.SizedBox(height: 6),
        ],
        pw.SizedBox(height: 8),
        pw.Text(
          m.depositHeading,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        for (final ({String label, String value}) r in m.depositRows)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: <pw.Widget>[pw.Text(r.label), pw.Text(r.value)],
            ),
          ),
        pw.SizedBox(height: 10),
        pw.Text(
          m.outstandingSentence,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        if (m.factsText != null) ...<pw.Widget>[
          pw.SizedBox(height: 10),
          pw.Text(
            m.factsHeading!,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(m.factsText!),
        ],
        pw.SizedBox(height: 10),
        pw.Text(m.deadlineSentence),
        if (m.paymentText != null) ...<pw.Widget>[
          pw.SizedBox(height: 10),
          pw.Text(
            m.paymentHeading!,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(m.paymentText!),
        ],
        if (m.documents.isNotEmpty) ...<pw.Widget>[
          pw.SizedBox(height: 10),
          pw.Text(
            m.docsHeading!,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          for (final String d in m.documents) pw.Bullet(text: d),
        ],
        pw.SizedBox(height: 12),
        pw.Text(m.furtherAction),
        pw.SizedBox(height: 24),
        pw.Text(m.closing),
        pw.SizedBox(height: 28),
        pw.Text(m.signatureName),
        pw.SizedBox(height: 24),
        pw.Divider(),
        pw.Text(
          m.footerDisclaimer,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ],
    ),
  );
  return doc.save();
}
