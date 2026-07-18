import 'package:flutter_test/flutter_test.dart';

import 'package:sewabukti/src/core/formatting/formatting.dart';
import 'package:sewabukti/src/features/cases/deposit_calculator.dart';

void main() {
  group('deposit calculator', () {
    test('total sums all deposit components', () {
      expect(
        totalDepositSen(
          security: 100000,
          utility: 50000,
          access: 10000,
          other: 5000,
        ),
        165000,
      );
    });

    test('claimed = total - refunded - accepted deductions', () {
      expect(
        amountClaimedSen(
          totalDeposit: 160000,
          refunded: 40000,
          acceptedDeductions: 20000,
        ),
        100000,
      );
    });

    test('claimed never goes below zero', () {
      expect(
        amountClaimedSen(
          totalDeposit: 100000,
          refunded: 90000,
          acceptedDeductions: 50000,
        ),
        0,
      );
    });

    test('with nothing refunded or accepted, claim equals total', () {
      expect(
        amountClaimedSen(
          totalDeposit: 100000,
          refunded: 0,
          acceptedDeductions: 0,
        ),
        100000,
      );
    });
  });

  group('RM formatting', () {
    test('formats sen as RM with two decimals and thousands separators', () {
      expect(formatRmFromSen(165000), 'RM 1,650.00');
      expect(formatRmFromSen(50), 'RM 0.50');
      expect(formatRmFromSen(0), 'RM 0.00');
    });

    test('parses RM strings into sen', () {
      expect(parseRmToSen('1500'), 150000);
      expect(parseRmToSen('1,500.50'), 150050);
      expect(parseRmToSen('RM 20'), 2000);
    });

    test('rejects invalid or negative amounts', () {
      expect(parseRmToSen(''), isNull);
      expect(parseRmToSen('abc'), isNull);
      expect(parseRmToSen('-5'), isNull);
    });
  });
}
