import 'package:sewabukti/src/features/cases/deposit_calculator.dart';

/// Other-party classification (§10.3). This organises information only and does
/// NOT determine the legally correct defendant.
enum OtherPartyType {
  landlord('landlord'),
  agent('agent'),
  management('management'),
  uncertain('uncertain');

  const OtherPartyType(this.code);
  final String code;

  static OtherPartyType? fromCode(String? code) {
    if (code == null) return null;
    for (final OtherPartyType t in OtherPartyType.values) {
      if (t.code == code) return t;
    }
    return null;
  }
}

/// A deposit-recovery case (mirrors the Turso `cases` schema / Edge Function
/// JSON). Money fields are integer sen (1 RM = 100 sen). Immutable; edits are
/// applied as partial field maps via the repository.
class Case {
  const Case({
    required this.id,
    this.status = 'active',
    this.propertyLine1,
    this.propertyLine2,
    this.propertyCity,
    this.propertyPostcode,
    this.propertyState,
    this.tenancyStartDate,
    this.tenancyEndDate,
    this.vacatedDate,
    this.keysReturnedDate,
    this.refundDeadlineDate,
    this.monthlyRentSen,
    this.claimantFullName,
    this.claimantIdNumber,
    this.claimantEmail,
    this.claimantPhone,
    this.claimantAddress,
    this.otherPartyType,
    this.otherPartyIsCompany = false,
    this.otherPartyName,
    this.otherPartyCompanyNo,
    this.otherPartyEmail,
    this.otherPartyPhone,
    this.otherPartyAddress,
    this.depositReceivedBy,
    this.depositPromisedBy,
    this.securityDepositSen = 0,
    this.utilityDepositSen = 0,
    this.accessDepositSen = 0,
    this.otherDepositSen = 0,
    this.amountRefundedSen = 0,
    this.deductionsAcceptedSen = 0,
    this.deductionsDisputedSen = 0,
    this.demandDeadlineDate,
  });

  final String id;
  final String status;

  final String? propertyLine1;
  final String? propertyLine2;
  final String? propertyCity;
  final String? propertyPostcode;
  final String? propertyState;

  final String? tenancyStartDate;
  final String? tenancyEndDate;
  final String? vacatedDate;
  final String? keysReturnedDate;
  final String? refundDeadlineDate;
  final int? monthlyRentSen;

  final String? claimantFullName;
  final String? claimantIdNumber;
  final String? claimantEmail;
  final String? claimantPhone;
  final String? claimantAddress;

  final OtherPartyType? otherPartyType;
  final bool otherPartyIsCompany;
  final String? otherPartyName;
  final String? otherPartyCompanyNo;
  final String? otherPartyEmail;
  final String? otherPartyPhone;
  final String? otherPartyAddress;
  final String? depositReceivedBy;
  final String? depositPromisedBy;

  final int securityDepositSen;
  final int utilityDepositSen;
  final int accessDepositSen;
  final int otherDepositSen;
  final int amountRefundedSen;
  final int deductionsAcceptedSen;
  final int deductionsDisputedSen;

  final String? demandDeadlineDate;

  int get totalDepositSenValue => totalDepositSen(
    security: securityDepositSen,
    utility: utilityDepositSen,
    access: accessDepositSen,
    other: otherDepositSen,
  );

  int get amountClaimedSenValue => amountClaimedSen(
    totalDeposit: totalDepositSenValue,
    refunded: amountRefundedSen,
    acceptedDeductions: deductionsAcceptedSen,
  );

  static int _asSen(Object? value) =>
      value is num ? value.toInt() : int.tryParse('${value ?? ''}') ?? 0;

  static String? _asString(Object? value) =>
      (value == null) ? null : value.toString();

  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      id: (json['id'] ?? '').toString(),
      status: (json['status'] ?? 'active').toString(),
      propertyLine1: _asString(json['property_line1']),
      propertyLine2: _asString(json['property_line2']),
      propertyCity: _asString(json['property_city']),
      propertyPostcode: _asString(json['property_postcode']),
      propertyState: _asString(json['property_state']),
      tenancyStartDate: _asString(json['tenancy_start_date']),
      tenancyEndDate: _asString(json['tenancy_end_date']),
      vacatedDate: _asString(json['vacated_date']),
      keysReturnedDate: _asString(json['keys_returned_date']),
      refundDeadlineDate: _asString(json['refund_deadline_date']),
      monthlyRentSen: json['monthly_rent_sen'] == null
          ? null
          : _asSen(json['monthly_rent_sen']),
      claimantFullName: _asString(json['claimant_full_name']),
      claimantIdNumber: _asString(json['claimant_id_number']),
      claimantEmail: _asString(json['claimant_email']),
      claimantPhone: _asString(json['claimant_phone']),
      claimantAddress: _asString(json['claimant_address']),
      otherPartyType: OtherPartyType.fromCode(
        _asString(json['other_party_type']),
      ),
      otherPartyIsCompany:
          json['other_party_is_company'] == 1 ||
          json['other_party_is_company'] == true,
      otherPartyName: _asString(json['other_party_name']),
      otherPartyCompanyNo: _asString(json['other_party_company_no']),
      otherPartyEmail: _asString(json['other_party_email']),
      otherPartyPhone: _asString(json['other_party_phone']),
      otherPartyAddress: _asString(json['other_party_address']),
      depositReceivedBy: _asString(json['deposit_received_by']),
      depositPromisedBy: _asString(json['deposit_promised_by']),
      securityDepositSen: _asSen(json['security_deposit_sen']),
      utilityDepositSen: _asSen(json['utility_deposit_sen']),
      accessDepositSen: _asSen(json['access_deposit_sen']),
      otherDepositSen: _asSen(json['other_deposit_sen']),
      amountRefundedSen: _asSen(json['amount_refunded_sen']),
      deductionsAcceptedSen: _asSen(json['deductions_accepted_sen']),
      deductionsDisputedSen: _asSen(json['deductions_disputed_sen']),
      demandDeadlineDate: _asString(json['demand_deadline_date']),
    );
  }

  /// Full snake_case JSON (used by the local repository for persistence).
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'status': status,
    'property_line1': propertyLine1,
    'property_line2': propertyLine2,
    'property_city': propertyCity,
    'property_postcode': propertyPostcode,
    'property_state': propertyState,
    'tenancy_start_date': tenancyStartDate,
    'tenancy_end_date': tenancyEndDate,
    'vacated_date': vacatedDate,
    'keys_returned_date': keysReturnedDate,
    'refund_deadline_date': refundDeadlineDate,
    'monthly_rent_sen': monthlyRentSen,
    'claimant_full_name': claimantFullName,
    'claimant_id_number': claimantIdNumber,
    'claimant_email': claimantEmail,
    'claimant_phone': claimantPhone,
    'claimant_address': claimantAddress,
    'other_party_type': otherPartyType?.code,
    'other_party_is_company': otherPartyIsCompany ? 1 : 0,
    'other_party_name': otherPartyName,
    'other_party_company_no': otherPartyCompanyNo,
    'other_party_email': otherPartyEmail,
    'other_party_phone': otherPartyPhone,
    'other_party_address': otherPartyAddress,
    'deposit_received_by': depositReceivedBy,
    'deposit_promised_by': depositPromisedBy,
    'security_deposit_sen': securityDepositSen,
    'utility_deposit_sen': utilityDepositSen,
    'access_deposit_sen': accessDepositSen,
    'other_deposit_sen': otherDepositSen,
    'amount_refunded_sen': amountRefundedSen,
    'deductions_accepted_sen': deductionsAcceptedSen,
    'deductions_disputed_sen': deductionsDisputedSen,
    'amount_claimed_sen': amountClaimedSenValue,
    'demand_deadline_date': demandDeadlineDate,
  };

  /// Applies a partial snake_case change map (used by the local repository to
  /// merge updates), recomputing derived values on read.
  Case mergedWith(Map<String, dynamic> changes) {
    final Map<String, dynamic> merged = toJson()..addAll(changes);
    return Case.fromJson(merged);
  }

  static Case newLocal(String id) => Case(id: id);
}
