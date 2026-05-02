class PoolStatementBreakdown {
  PoolStatementBreakdown({
    required this.poolId,
    required this.poolName,
    required this.roundNumbers,
    required this.roundIds,
    required this.roundDates,
    required this.isPaid,
    required this.payAmount,
    required this.receiveAmount,
  });

  final int poolId;
  final String poolName;
  final List<int> roundNumbers;
  final List<int> roundIds;
  final List<DateTime> roundDates;
  final bool isPaid;
  final int payAmount;
  final int receiveAmount;

  int get netBalance => receiveAmount - payAmount;
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
  bool get isAllPaid =>
      breakdowns.isNotEmpty && breakdowns.every((b) => b.isPaid);
}
