import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sewabukti/src/core/formatting/formatting.dart';
import 'package:sewabukti/src/core/routing/routes.dart';
import 'package:sewabukti/src/core/theme/app_colors.dart';
import 'package:sewabukti/src/features/cases/case_controller.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/features/cases/deposit_calculator.dart';
import 'package:sewabukti/src/features/shared/widgets/language_selector.dart';
import 'package:sewabukti/src/features/shared/widgets/legal_notice.dart';
import 'package:sewabukti/src/l10n/app_localizations.dart';

/// Case creation/edit wizard (§10.3). Loads or creates the user's single case,
/// then edits it step by step, saving after each step (FR-CASE-02/03).
class CaseWizardPage extends ConsumerWidget {
  const CaseWizardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Case?> state = ref.watch(caseControllerProvider);

    return state.when(
      loading: () =>
          _scaffold(l10n, const Center(child: CircularProgressIndicator())),
      error: (_, _) => _scaffold(l10n, Center(child: Text(l10n.signInFailed))),
      data: (Case? c) =>
          c == null ? const _EnsureCase() : _CaseWizardView(initialCase: c),
    );
  }

  Widget _scaffold(AppLocalizations l10n, Widget body) => Scaffold(
    appBar: AppBar(
      title: Text(l10n.caseWizardTitle),
      actions: const <Widget>[LanguageSelector(compact: true)],
    ),
    body: SafeArea(child: body),
  );
}

/// Creates the draft case when none exists yet, then the parent rebuilds.
class _EnsureCase extends ConsumerStatefulWidget {
  const _EnsureCase();
  @override
  ConsumerState<_EnsureCase> createState() => _EnsureCaseState();
}

class _EnsureCaseState extends ConsumerState<_EnsureCase> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      try {
        await ref.read(caseControllerProvider.notifier).createDraft();
      } catch (_) {
        // Leave the spinner; the user can go back to the dashboard.
      }
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SafeArea(child: Center(child: CircularProgressIndicator())),
  );
}

class _CaseWizardView extends ConsumerStatefulWidget {
  const _CaseWizardView({required this.initialCase});
  final Case initialCase;

  @override
  ConsumerState<_CaseWizardView> createState() => _CaseWizardViewState();
}

class _CaseWizardViewState extends ConsumerState<_CaseWizardView> {
  static const int _stepCount = 5; // 4 form steps + review

  static const List<String> _textCols = <String>[
    'property_line1',
    'property_line2',
    'property_city',
    'property_postcode',
    'property_state',
    'claimant_full_name',
    'claimant_id_number',
    'claimant_email',
    'claimant_phone',
    'claimant_address',
    'other_party_name',
    'other_party_company_no',
    'other_party_email',
    'other_party_phone',
    'other_party_address',
    'deposit_received_by',
    'deposit_promised_by',
  ];
  static const List<String> _moneyCols = <String>[
    'monthly_rent_sen',
    'security_deposit_sen',
    'utility_deposit_sen',
    'access_deposit_sen',
    'other_deposit_sen',
    'amount_refunded_sen',
    'deductions_accepted_sen',
    'deductions_disputed_sen',
  ];
  static const List<String> _dateCols = <String>[
    'tenancy_start_date',
    'tenancy_end_date',
    'vacated_date',
    'keys_returned_date',
    'refund_deadline_date',
  ];

  final Map<String, TextEditingController> _c =
      <String, TextEditingController>{};
  final Map<String, String?> _dates = <String, String?>{};
  OtherPartyType? _partyType;
  bool _isCompany = false;

  final List<GlobalKey<FormState>> _formKeys =
      List<GlobalKey<FormState>>.generate(4, (_) => GlobalKey<FormState>());
  int _step = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> json = widget.initialCase.toJson();
    for (final String col in _textCols) {
      final String initial = (json[col] as String?) ?? '';
      _c[col] = col == 'claimant_id_number'
          ? _MaskingTextController(text: initial)
          : TextEditingController(text: initial);
    }
    for (final String col in _moneyCols) {
      final int sen = (json[col] as int?) ?? 0;
      _c[col] = TextEditingController(
        text: sen > 0 ? (sen / 100).toStringAsFixed(2) : '',
      );
    }
    for (final String col in _dateCols) {
      _dates[col] = json[col] as String?;
    }
    _partyType = widget.initialCase.otherPartyType;
    _isCompany = widget.initialCase.otherPartyIsCompany;
  }

  @override
  void dispose() {
    for (final TextEditingController c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _collectStep(int step) {
    final Map<String, dynamic> m = <String, dynamic>{};
    void money(String col) {
      final int? sen = parseRmToSen(_c[col]!.text);
      if (col == 'monthly_rent_sen') {
        if (sen != null) m[col] = sen;
      } else {
        m[col] = sen ?? 0;
      }
    }

    switch (step) {
      case 0:
        for (final String col in <String>[
          'property_line1',
          'property_line2',
          'property_city',
          'property_postcode',
          'property_state',
        ]) {
          m[col] = _c[col]!.text.trim();
        }
        for (final String col in _dateCols) {
          m[col] = _dates[col] ?? '';
        }
        money('monthly_rent_sen');
      case 1:
        for (final String col in <String>[
          'claimant_full_name',
          'claimant_id_number',
          'claimant_email',
          'claimant_phone',
          'claimant_address',
        ]) {
          m[col] = _c[col]!.text.trim();
        }
      case 2:
        for (final String col in <String>[
          'other_party_name',
          'other_party_company_no',
          'other_party_email',
          'other_party_phone',
          'other_party_address',
          'deposit_received_by',
          'deposit_promised_by',
        ]) {
          m[col] = _c[col]!.text.trim();
        }
        if (_partyType != null) m['other_party_type'] = _partyType!.code;
        m['other_party_is_company'] = _isCompany ? 1 : 0;
      case 3:
        for (final String col in <String>[
          'security_deposit_sen',
          'utility_deposit_sen',
          'access_deposit_sen',
          'other_deposit_sen',
          'amount_refunded_sen',
          'deductions_accepted_sen',
          'deductions_disputed_sen',
        ]) {
          money(col);
        }
    }
    return m;
  }

  Future<bool> _saveStep(int step) async {
    if (step >= 4) return true; // review has nothing to persist
    setState(() => _saving = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(caseControllerProvider.notifier)
          .saveFields(_collectStep(step));
      messenger.showSnackBar(SnackBar(content: Text(l10n.wizardSavedToast)));
      return true;
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.signInFailed)));
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _validateStep(int step) {
    if (step < 4) {
      final bool ok = _formKeys[step].currentState?.validate() ?? true;
      if (!ok) return false;
    }
    return true;
  }

  Future<void> _onNext() async {
    if (!_validateStep(_step)) return;
    final bool saved = await _saveStep(_step);
    if (!saved || !mounted) return;
    if (_step < _stepCount - 1) setState(() => _step++);
  }

  void _onBack() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.go(Routes.dashboard);
    }
  }

  Future<void> _onSaveExit() async {
    if (_step < 4 && !_validateStep(_step)) return;
    final GoRouter router = GoRouter.of(context);
    final bool saved = await _saveStep(_step);
    if (saved && mounted) router.go(Routes.dashboard);
  }

  void _onFinish() => context.go(Routes.dashboard);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> titles = <String>[
      l10n.stepTenancyTitle,
      l10n.stepClaimantTitle,
      l10n.stepOtherPartyTitle,
      l10n.stepDepositTitle,
      l10n.stepReviewTitle,
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBack,
        ),
        title: Text(l10n.caseWizardTitle),
        actions: <Widget>[
          const LanguageSelector(compact: true),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: l10n.wizardSaveExit,
            onPressed: _saving ? null : _onSaveExit,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.wizardStepOf(_step + 1, _stepCount),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_step + 1) / _stepCount,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        titles[_step],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: _stepBody(l10n),
                  ),
                ),
                _bottomBar(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepBody(AppLocalizations l10n) {
    switch (_step) {
      case 0:
        return _tenancyStep(l10n);
      case 1:
        return _claimantStep(l10n);
      case 2:
        return _otherPartyStep(l10n);
      case 3:
        return _depositStep(l10n);
      default:
        return _reviewStep(l10n);
    }
  }

  Widget _bottomBar(AppLocalizations l10n) {
    final bool isReview = _step == _stepCount - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: <Widget>[
          OutlinedButton(
            onPressed: _saving ? null : _onBack,
            child: Text(l10n.wizardBack),
          ),
          const Spacer(),
          FilledButton(
            onPressed: _saving ? null : (isReview ? _onFinish : _onNext),
            child: Text(isReview ? l10n.wizardFinish : l10n.wizardNext),
          ),
        ],
      ),
    );
  }

  // --- Field helpers -------------------------------------------------------

  Widget _field(
    String col,
    String label, {
    String? hint,
    TextInputType? keyboard,
    String? Function(String?)? validator,
    Widget? suffix,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _c[col],
        keyboardType: keyboard,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          helperText: hint,
          suffixIcon: suffix,
        ),
      ),
    );
  }

  Widget _money(String col, String label, {bool live = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _c[col],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: live ? (_) => setState(() {}) : null,
        validator: (String? v) {
          if (v == null || v.trim().isEmpty) return null;
          return parseRmToSen(v) == null
              ? AppLocalizations.of(context).invalidAmount
              : null;
        },
        decoration: InputDecoration(labelText: label, prefixText: 'RM '),
      ),
    );
  }

  Widget _dateField(String col, String label) {
    final Locale locale = Localizations.localeOf(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? iso = _dates[col];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final DateTime now = DateTime.now();
          final DateTime initial =
              (iso != null && iso.isNotEmpty ? DateTime.tryParse(iso) : null) ??
              now;
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: DateTime(2010),
            lastDate: DateTime(now.year + 5),
          );
          if (picked != null) setState(() => _dates[col] = toIsoDate(picked));
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
          ),
          child: Text(
            (iso == null || iso.isEmpty)
                ? l10n.selectDate
                : formatIsoDate(iso, locale),
          ),
        ),
      ),
    );
  }

  String? _required(String? v, AppLocalizations l10n) =>
      (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

  String? _emailValidator(
    String? v,
    AppLocalizations l10n, {
    bool required = false,
  }) {
    if (v == null || v.trim().isEmpty) {
      return required ? l10n.fieldRequired : null;
    }
    final bool ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : l10n.invalidEmail;
  }

  // --- Steps ---------------------------------------------------------------

  Widget _tenancyStep(AppLocalizations l10n) {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _field(
            'property_line1',
            l10n.fieldAddressLine1,
            validator: (String? v) => _required(v, l10n),
          ),
          _field('property_line2', l10n.fieldAddressLine2),
          _field('property_city', l10n.fieldCity),
          _field(
            'property_postcode',
            l10n.fieldPostcode,
            keyboard: TextInputType.number,
          ),
          _field('property_state', l10n.fieldState),
          _dateField('tenancy_start_date', l10n.fieldTenancyStart),
          _dateField('tenancy_end_date', l10n.fieldTenancyEnd),
          _dateField('vacated_date', l10n.fieldVacatedDate),
          _dateField('keys_returned_date', l10n.fieldKeysReturned),
          _dateField('refund_deadline_date', l10n.fieldRefundDeadline),
          _money('monthly_rent_sen', l10n.fieldMonthlyRent),
        ],
      ),
    );
  }

  Widget _claimantStep(AppLocalizations l10n) {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _field(
            'claimant_full_name',
            l10n.fieldFullName,
            validator: (String? v) => _required(v, l10n),
          ),
          _IdNumberField(
            controller: _c['claimant_id_number']! as _MaskingTextController,
            label: l10n.fieldIdNumber,
            hint: l10n.fieldIdNumberHint,
          ),
          _field(
            'claimant_email',
            l10n.fieldEmail,
            keyboard: TextInputType.emailAddress,
            hint: l10n.fieldEmailFromGoogleHint,
            validator: (String? v) => _emailValidator(v, l10n, required: true),
          ),
          _field(
            'claimant_phone',
            l10n.fieldPhone,
            keyboard: TextInputType.phone,
          ),
          _field('claimant_address', l10n.fieldCorrespondenceAddress),
        ],
      ),
    );
  }

  Widget _otherPartyStep(AppLocalizations l10n) {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: context.sb.paleSeaBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: context.sb.onPaleSeaBlue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.otherPartyDisclaimer,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.sb.onPaleSeaBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.fieldPartyType,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Wrap(
            spacing: 8,
            children: <Widget>[
              for (final OtherPartyType t in OtherPartyType.values)
                ChoiceChip(
                  label: Text(_partyTypeLabel(t, l10n)),
                  selected: _partyType == t,
                  onSelected: (_) => setState(() => _partyType = t),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.fieldPartyIsCompany),
            value: _isCompany,
            onChanged: (bool v) => setState(() => _isCompany = v),
          ),
          const SizedBox(height: 8),
          _field(
            'other_party_name',
            l10n.fieldPartyName,
            validator: (String? v) => _required(v, l10n),
          ),
          if (_isCompany)
            _field('other_party_company_no', l10n.fieldPartyCompanyNo),
          _field(
            'other_party_email',
            l10n.fieldPartyEmail,
            keyboard: TextInputType.emailAddress,
            validator: (String? v) => _emailValidator(v, l10n),
          ),
          _field(
            'other_party_phone',
            l10n.fieldPartyPhone,
            keyboard: TextInputType.phone,
          ),
          _field('other_party_address', l10n.fieldPartyAddress),
          _field('deposit_received_by', l10n.fieldDepositReceivedBy),
          _field('deposit_promised_by', l10n.fieldDepositPromisedBy),
        ],
      ),
    );
  }

  Widget _depositStep(AppLocalizations l10n) {
    int senOf(String col) => parseRmToSen(_c[col]!.text) ?? 0;
    final int total = totalDepositSen(
      security: senOf('security_deposit_sen'),
      utility: senOf('utility_deposit_sen'),
      access: senOf('access_deposit_sen'),
      other: senOf('other_deposit_sen'),
    );
    final int claimed = amountClaimedSen(
      totalDeposit: total,
      refunded: senOf('amount_refunded_sen'),
      acceptedDeductions: senOf('deductions_accepted_sen'),
    );

    return Form(
      key: _formKeys[3],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _money('security_deposit_sen', l10n.fieldSecurityDeposit, live: true),
          _money('utility_deposit_sen', l10n.fieldUtilityDeposit, live: true),
          _money('access_deposit_sen', l10n.fieldAccessDeposit, live: true),
          _money('other_deposit_sen', l10n.fieldOtherDeposit, live: true),
          _calcRow(l10n.labelTotalDeposit, total, emphasise: false),
          const Divider(height: 24),
          _money('amount_refunded_sen', l10n.fieldAmountRefunded, live: true),
          _money(
            'deductions_accepted_sen',
            l10n.fieldDeductionsAccepted,
            live: true,
          ),
          _money('deductions_disputed_sen', l10n.fieldDeductionsDisputed),
          const SizedBox(height: 8),
          _calcRow(l10n.labelTotalClaimed, claimed, emphasise: true),
        ],
      ),
    );
  }

  Widget _reviewStep(AppLocalizations l10n) {
    final Case? c = ref.watch(caseControllerProvider).asData?.value;
    final Locale locale = Localizations.localeOf(context);
    String orNot(String? v) => (v == null || v.isEmpty) ? l10n.reviewNoData : v;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _reviewLine(l10n.fieldAddressLine1, orNot(c?.propertyLine1)),
                _reviewLine(
                  l10n.fieldTenancyStart,
                  orNot(formatIsoDate(c?.tenancyStartDate, locale)),
                ),
                _reviewLine(l10n.fieldFullName, orNot(c?.claimantFullName)),
                _reviewLine(l10n.fieldPartyName, orNot(c?.otherPartyName)),
                _reviewLine(
                  l10n.labelTotalDeposit,
                  formatRmFromSen(c?.totalDepositSenValue ?? 0),
                ),
                _reviewLine(
                  l10n.labelTotalClaimed,
                  formatRmFromSen(c?.amountClaimedSenValue ?? 0),
                  emphasise: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.sb.paleSeaBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            l10n.reviewConfirmHint,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.sb.onPaleSeaBlue),
          ),
        ),
        const SizedBox(height: 16),
        const LegalServiceNotice(),
      ],
    );
  }

  Widget _calcRow(String label, int sen, {required bool emphasise}) {
    final TextStyle? style = emphasise
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.sb.deepSeaBlue,
          )
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: style),
          Text(formatRmFromSen(sen), style: style),
        ],
      ),
    );
  }

  Widget _reviewLine(String label, String value, {bool emphasise = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: emphasise ? FontWeight.w700 : FontWeight.w400,
              color: emphasise ? context.sb.deepSeaBlue : null,
            ),
          ),
        ],
      ),
    );
  }

  String _partyTypeLabel(OtherPartyType t, AppLocalizations l10n) =>
      switch (t) {
        OtherPartyType.landlord => l10n.partyTypeLandlord,
        OtherPartyType.agent => l10n.partyTypeAgent,
        OtherPartyType.management => l10n.partyTypeManagement,
        OtherPartyType.uncertain => l10n.partyTypeUncertain,
      };
}

/// Masks a value to its last 4 characters (e.g. `••••1234`); short values are
/// fully masked so nothing is exposed.
String _maskId(String value) {
  final String t = value.trim();
  if (t.isEmpty) return '';
  if (t.length <= 4) return '•' * t.length;
  return '${'•' * (t.length - 4)}${t.substring(t.length - 4)}';
}

/// A [TextEditingController] whose *displayed* text is masked while [masked] is
/// true; `.text` always returns the real value (used when saving).
class _MaskingTextController extends TextEditingController {
  _MaskingTextController({super.text});

  bool masked = true;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (masked && text.isNotEmpty) {
      return TextSpan(style: style, text: _maskId(text));
    }
    return super.buildTextSpan(
      context: context,
      style: style,
      withComposing: withComposing,
    );
  }
}

/// Identity-number field: masked to the last 4 characters by default; revealed
/// while focused (for editing) or via the eye toggle (§10.3, NFR-SEC-09). The
/// value is encrypted at rest server-side and is not persisted to browser
/// storage in the demo build.
class _IdNumberField extends StatefulWidget {
  const _IdNumberField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final _MaskingTextController controller;
  final String label;
  final String hint;

  @override
  State<_IdNumberField> createState() => _IdNumberFieldState();
}

class _IdNumberFieldState extends State<_IdNumberField> {
  final FocusNode _focus = FocusNode();
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_onFocusChanged);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    widget.controller.masked = !_revealed && !_focus.hasFocus;
    final bool hasValue = widget.controller.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: widget.hint,
          suffixIcon: hasValue
              ? IconButton(
                  tooltip: _revealed ? l10n.hideLabel : l10n.showLabel,
                  icon: Icon(
                    _revealed
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _revealed = !_revealed),
                )
              : null,
        ),
      ),
    );
  }
}
