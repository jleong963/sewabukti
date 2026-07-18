import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sewabukti/src/features/cases/case_model.dart';
import 'package:sewabukti/src/features/cases/case_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LocalCaseRepository saves, recalculates claim, and resumes', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final LocalCaseRepository repo = LocalCaseRepository(prefs);

    final Case created = await repo.createCase();
    expect(created.id, isNotEmpty);
    expect(created.status, 'active');

    await repo.updateCase(created.id, <String, dynamic>{
      'claimant_full_name': 'Aisyah',
      'claimant_id_number': '900101-01-1234',
      'security_deposit_sen': 150000,
      'utility_deposit_sen': 50000,
      'amount_refunded_sen': 40000,
      'deductions_accepted_sen': 10000,
    });

    // Resume: a fresh read returns the persisted data with the recalculated
    // claim (200000 total − 40000 refunded − 10000 accepted = 150000).
    final Case? resumed = await repo.getCurrentCase();
    expect(resumed, isNotNull);
    expect(resumed!.claimantFullName, 'Aisyah');
    expect(resumed.totalDepositSenValue, 200000);
    expect(resumed.amountClaimedSenValue, 150000);
    // Identity number is never written to local browser storage.
    expect(resumed.claimantIdNumber, isNull);

    // Only one case per user: createCase returns the existing one.
    final Case again = await repo.createCase();
    expect(again.id, created.id);
  });
}
