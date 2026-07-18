/// Pure deposit/claim calculations in integer sen (1 RM = 100 sen).
///
/// Mirrors the server-side calculation (Edge Function `cases.ts`) so the UI can
/// show live totals before saving; the server value remains authoritative
/// (FR-CASE-06). Kept dependency-free for straightforward unit testing (§19).
library;

int totalDepositSen({
  required int security,
  required int utility,
  required int access,
  required int other,
}) => security + utility + access + other;

/// Amount currently claimed = total deposit − refunded − accepted deductions.
/// Disputed deductions remain part of the claim; never returns below zero.
int amountClaimedSen({
  required int totalDeposit,
  required int refunded,
  required int acceptedDeductions,
}) {
  final int claimed = totalDeposit - refunded - acceptedDeductions;
  return claimed > 0 ? claimed : 0;
}
