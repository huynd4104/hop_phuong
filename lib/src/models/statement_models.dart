class StatementPaymentEntry {
  final int amount;
  final DateTime date;
  final String? note;

  StatementPaymentEntry({
    required this.amount,
    required this.date,
    this.note,
  });
}

class PoolStatementBreakdown {
  PoolStatementBreakdown({
    required this.poolId,
    required this.poolName,
    required this.roundNumbers,
    required this.roundIds,
    required this.roundDates,
    required this.payAmount,
    required this.receiveAmount,
    required this.actualAmount,
    required this.notes,
    this.history = const [],
  });

  final int poolId;
  final String poolName;
  final List<int> roundNumbers;
  final List<int> roundIds;
  final List<DateTime> roundDates;
  bool get isPaid => remainingBalance == 0;
  final int payAmount;
  final int receiveAmount;
  final int actualAmount;
  final List<String> notes;
  final List<StatementPaymentEntry> history;

  int get netBalance => receiveAmount - payAmount;
  int get remainingBalance => netBalance - actualAmount;
  int get debt => -remainingBalance; // positive means they owe, negative means they paid extra
}

class StatementRoundOption {
  StatementRoundOption({
    required this.roundId,
    required this.poolId,
    required this.poolName,
    required this.poolStartDate,
    required this.roundNumber,
    required this.date,
  });

  final int roundId;
  final int poolId;
  final String poolName;
  final DateTime poolStartDate;
  final int roundNumber;
  final DateTime date;
}

class UserMonthlyStatement {
  UserMonthlyStatement({
    required this.userId,
    required this.userName,
    required this.phone,
    required this.totalPay,
    required this.totalReceive,
    required this.breakdowns,
  });

  final int userId;
  final String userName;
  final String phone;
  final int totalPay;
  final int totalReceive;
  final List<PoolStatementBreakdown> breakdowns;

  int get netBalance => totalReceive - totalPay;
  int get totalActualAmount => breakdowns.fold(0, (sum, b) => sum + b.actualAmount);
  int get remainingBalance => netBalance - totalActualAmount;
  bool get isAllPaid =>
      breakdowns.isNotEmpty && breakdowns.every((b) => b.isPaid);
}
