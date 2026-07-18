import 'package:flutter_test/flutter_test.dart';

import 'package:sewabukti/src/features/cases/case_controller.dart';
import 'package:sewabukti/src/features/cases/case_model.dart';

void main() {
  test('no case or an empty case is 0% complete', () {
    expect(caseCompletionPercent(null), 0);
    expect(caseCompletionPercent(const Case(id: 'c1')), 0);
  });

  test('an empty-string date does not count as a completed section', () {
    // The wizard persists unset dates as '' (not null); the tenancy section
    // must not be credited until a start date is actually selected.
    const Case c = Case(id: 'c1', propertyLine1: '12 Jalan Mawar');
    expect(caseCompletionPercent(c.mergedWith({'tenancy_start_date': ''})), 0);
    expect(
      caseCompletionPercent(c.mergedWith({'tenancy_start_date': '2026-01-05'})),
      25,
    );
  });

  test('all four sections filled is 100%', () {
    const Case c = Case(
      id: 'c1',
      propertyLine1: '12 Jalan Mawar',
      tenancyStartDate: '2026-01-05',
      claimantFullName: 'Aisyah',
      claimantEmail: 'aisyah@example.com',
      otherPartyName: 'Landlord Sdn Bhd',
      otherPartyType: OtherPartyType.landlord,
      securityDepositSen: 150000,
    );
    expect(caseCompletionPercent(c), 100);
  });
}
