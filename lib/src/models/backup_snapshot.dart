class BackupSnapshot {
  BackupSnapshot({
    required this.users,
    required this.pools,
    required this.poolMembers,
    required this.rounds,
    required this.paymentStatuses,
  });

  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> pools;
  final List<Map<String, dynamic>> poolMembers;
  final List<Map<String, dynamic>> rounds;
  final List<Map<String, dynamic>> paymentStatuses;

  Map<String, dynamic> toJson() => {
        'users': users,
        'pools': pools,
        'poolMembers': poolMembers,
        'rounds': rounds,
        'paymentStatuses': paymentStatuses,
      };

  factory BackupSnapshot.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> readList(String key) {
      final raw = json[key];
      if (raw is! List) {
        return <Map<String, dynamic>>[];
      }
      return raw
          .whereType<Map>()
          .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }

    return BackupSnapshot(
      users: readList('users'),
      pools: readList('pools'),
      poolMembers: readList('poolMembers'),
      rounds: readList('rounds'),
      paymentStatuses: readList('paymentStatuses'),
    );
  }
}
