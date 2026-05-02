class FinancialResult {
  FinancialResult({
    required this.totalPot,
    required this.bidAmount,
    required this.payoutAmount,
    required this.contributionAmount,
    required this.netReceiveAmount,
  });

  final int totalPot;
  final int bidAmount;
  final int payoutAmount;
  final int contributionAmount;
  final int netReceiveAmount;
}

class FinancialCalculator {
  const FinancialCalculator._();

  static int roundUpToThousand(int amount) {
    if (amount <= 0) {
      return 0;
    }
    return ((amount + 999) ~/ 1000) * 1000;
  }

  static FinancialResult calculate({
    required int memberCount,
    required int baseAmount,
    required int bidAmount,
  }) {
    if (memberCount <= 0) {
      throw ArgumentError.value(memberCount, 'memberCount', 'Must be greater than zero');
    }
    if (baseAmount < 0) {
      throw ArgumentError.value(baseAmount, 'baseAmount', 'Must not be negative');
    }

    final totalPot = memberCount * baseAmount;
    if (bidAmount < 0 || bidAmount > totalPot) {
      throw ArgumentError.value(bidAmount, 'bidAmount', 'Must be between 0 and $totalPot');
    }

    final payoutAmount = totalPot - bidAmount;
    final roundedContribution = roundUpToThousand((payoutAmount / memberCount).ceil());

    return FinancialResult(
      totalPot: totalPot,
      bidAmount: bidAmount,
      payoutAmount: payoutAmount,
      contributionAmount: roundedContribution,
      netReceiveAmount: payoutAmount - roundedContribution,
    );
  }
}
