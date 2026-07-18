import 'package:flutter/material.dart';

import 'package:sewabukti/src/l10n/app_localizations.dart';

/// The evidence categories from §10.4. [code] is the stable value stored in the
/// `evidence_files.category` column.
enum EvidenceCategory {
  tenancyAgreement('tenancy_agreement', Icons.description_outlined),
  stampedAgreement('stamped_agreement', Icons.verified_outlined),
  depositReceipt('deposit_receipt', Icons.receipt_long_outlined),
  moveInPhotos('movein_photos', Icons.photo_camera_outlined),
  moveOutPhotos('moveout_photos', Icons.photo_camera_back_outlined),
  handoverKeys('handover_keys', Icons.vpn_key_outlined),
  inspectionReport('inspection_report', Icons.fact_check_outlined),
  utilityBills('utility_bills', Icons.bolt_outlined),
  messages('messages', Icons.chat_outlined),
  emails('emails', Icons.email_outlined),
  deductionStatement('deduction_statement', Icons.request_quote_outlined),
  repairQuote('repair_quote', Icons.build_outlined),
  repairReceipt('repair_receipt', Icons.receipt_outlined),
  priorRequests('prior_requests', Icons.history_outlined),
  demandDelivery('demand_delivery', Icons.local_post_office_outlined),
  other('other', Icons.attach_file_outlined);

  const EvidenceCategory(this.code, this.icon);

  final String code;
  final IconData icon;

  static EvidenceCategory fromCode(String? code) =>
      EvidenceCategory.values.firstWhere(
        (EvidenceCategory c) => c.code == code,
        orElse: () => EvidenceCategory.other,
      );

  String label(AppLocalizations l10n) => switch (this) {
    EvidenceCategory.tenancyAgreement => l10n.evCatTenancyAgreement,
    EvidenceCategory.stampedAgreement => l10n.evCatStampedAgreement,
    EvidenceCategory.depositReceipt => l10n.evCatDepositReceipt,
    EvidenceCategory.moveInPhotos => l10n.evCatMoveInPhotos,
    EvidenceCategory.moveOutPhotos => l10n.evCatMoveOutPhotos,
    EvidenceCategory.handoverKeys => l10n.evCatHandoverKeys,
    EvidenceCategory.inspectionReport => l10n.evCatInspectionReport,
    EvidenceCategory.utilityBills => l10n.evCatUtilityBills,
    EvidenceCategory.messages => l10n.evCatMessages,
    EvidenceCategory.emails => l10n.evCatEmails,
    EvidenceCategory.deductionStatement => l10n.evCatDeductionStatement,
    EvidenceCategory.repairQuote => l10n.evCatRepairQuote,
    EvidenceCategory.repairReceipt => l10n.evCatRepairReceipt,
    EvidenceCategory.priorRequests => l10n.evCatPriorRequests,
    EvidenceCategory.demandDelivery => l10n.evCatDemandDelivery,
    EvidenceCategory.other => l10n.evCatOther,
  };
}
