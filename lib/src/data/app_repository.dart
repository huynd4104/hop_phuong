import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:lunar_calendar/lunar_calendar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hop_phuong/src/models/backup_snapshot.dart';
import 'package:hop_phuong/src/models/payment_status_entity.dart';
import 'package:hop_phuong/src/models/pool_entity.dart';
import 'package:hop_phuong/src/models/pool_member_entity.dart';
import 'package:hop_phuong/src/models/round_entity.dart';
import 'package:hop_phuong/src/models/statement_models.dart';
import 'package:hop_phuong/src/models/user_entity.dart';
import '../services/financial_calculator.dart';
import '../services/lunar_schedule_service.dart';

class AppRepository {
  AppRepository._(this._isar);

  final Isar? _isar;
  final LunarScheduleService _lunarScheduleService =
      const LunarScheduleService();

  // Cache the Future itself to prevent race conditions with concurrent calls
  static Future<AppRepository>? _openFuture;

  // Mock data for Web
  static final List<User> _mockUsers = [];
  static final List<Pool> _mockPools = [];
  static final List<PoolMember> _mockPoolMembers = [];
  static final List<Round> _mockRounds = [];
  static final List<PaymentStatus> _mockPaymentStatuses = [];
  static int _webIdCounter = DateTime.now().millisecondsSinceEpoch;

  static int _getNextWebId() => ++_webIdCounter;

  static Future<AppRepository> open() {
    _openFuture ??= _openInternal();
    return _openFuture!;
  }

  static Future<AppRepository> _openInternal() async {
    if (kIsWeb) {
      return AppRepository._(null);
    }

    final directory = await getApplicationDocumentsDirectory();
    final isarDirectory = Directory('${directory.path}/hop_phuong_isar');
    if (!await isarDirectory.exists()) {
      await isarDirectory.create(recursive: true);
    }

    try {
      final isar = await Isar.open(
        [
          UserSchema,
          PoolSchema,
          PoolMemberSchema,
          RoundSchema,
          PaymentStatusSchema,
        ],
        directory: isarDirectory.path,
        inspector: !kReleaseMode,
      );
      final repo = AppRepository._(isar);
      await repo._ensureOwnerExists();
      return repo;
    } catch (e) {
      debugPrint('Isar open failed ($e). Resetting database...');

      // 1. Attempt to close any lingering instance that was partially opened
      try {
        final existingNames = Isar.instanceNames;
        for (final name in existingNames) {
          final instance = Isar.getInstance(name);
          if (instance != null) {
            await instance.close(deleteFromDisk: false);
          }
        }
      } catch (closeError) {
        debugPrint('Failed to close lingering Isar instances: $closeError');
      }

      // 2. Delete the directory to start fresh
      try {
        if (await isarDirectory.exists()) {
          await isarDirectory.delete(recursive: true);
        }
        await isarDirectory.create(recursive: true);
      } catch (deleteError) {
        debugPrint('Failed to delete Isar directory: $deleteError');
      }

      // 3. Re-open with a unique name to completely bypass any native registry collisions
      final fallbackName = 'db_reset_${DateTime.now().millisecondsSinceEpoch}';
      final isar = await Isar.open(
        [
          UserSchema,
          PoolSchema,
          PoolMemberSchema,
          RoundSchema,
          PaymentStatusSchema,
        ],
        directory: isarDirectory.path,
        name: fallbackName,
        inspector: !kReleaseMode,
      );
      final repo = AppRepository._(isar);
      await repo._ensureOwnerExists();
      return repo;
    }
  }

  Future<void> close() async {
    await _isar?.close();
  }

  Future<void> clearAll() async {
    if (kIsWeb) {
      _mockUsers.clear();
      _mockPools.clear();
      _mockPoolMembers.clear();
      _mockRounds.clear();
      _mockPaymentStatuses.clear();
      await _ensureOwnerExists();
      return;
    }
    await _isar!.writeTxn(() async {
      await _isar!.paymentStatus.clear();
      await _isar!.rounds.clear();
      await _isar!.poolMembers.clear();
      await _isar!.pools.clear();
      await _isar!.users.clear();
    });
    await _ensureOwnerExists();
  }

  Future<void> _ensureOwnerExists() async {
    if (kIsWeb) {
      final exists = _mockUsers.any((u) => u.isOwner);
      if (!exists) {
        _mockUsers.add(
          User(
            id: _getNextWebId(),
            name: 'Chủ hội',
            phone: '0000000000',
            isOwner: true,
          ),
        );
      }
      return;
    }
    final owner = await _isar!.users.filter().isOwnerEqualTo(true).findFirst();
    if (owner == null) {
      await _isar!.writeTxn(() async {
        await _isar!.users.put(
          User(name: 'Chủ hội', phone: '0000000000', isOwner: true),
        );
      });
    }
  }

  Future<List<User>> getUsers({String query = ''}) async {
    List<User> users;
    if (kIsWeb) {
      users = List.from(_mockUsers);
    } else {
      users = await _isar!.users.where().anyId().findAll();
    }

    users.sort(_compareUsers);
    if (query.trim().isEmpty) {
      return users;
    }

    final normalized = query.toLowerCase();
    return users
        .where(
          (user) =>
              user.name.toLowerCase().contains(normalized) ||
              user.phone.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  Future<User?> getUserById(int id) async {
    if (kIsWeb) {
      return _mockUsers.cast<User?>().firstWhere(
        (u) => u?.id == id,
        orElse: () => null,
      );
    }
    return _isar!.users.get(id);
  }

  Future<User> saveUser({
    int? id,
    required String name,
    required String phone,
  }) async {
    if (kIsWeb) {
      final newId = id ?? _getNextWebId();
      final user = User(id: newId, name: name.trim(), phone: phone.trim());
      final index = _mockUsers.indexWhere((u) => u.id == newId);
      if (index >= 0) {
        _mockUsers[index] = user;
      } else {
        _mockUsers.add(user);
      }
      return user;
    }

    final user = User(
      id: id ?? Isar.autoIncrement,
      name: name.trim(),
      phone: phone.trim(),
    );
    await _isar!.writeTxn(() async {
      user.id = await _isar!.users.put(user);
    });
    return user;
  }

  Future<void> deleteUser(int id) async {
    if (kIsWeb) {
      final user = _mockUsers.cast<User?>().firstWhere(
        (u) => u?.id == id,
        orElse: () => null,
      );
      if (user?.isOwner == true) {
        throw StateError('Không thể xóa Chủ hội.');
      }
      _mockUsers.removeWhere((u) => u.id == id);
      _mockPoolMembers.removeWhere((m) => m.userId == id);
      _mockPaymentStatuses.removeWhere((ps) => ps.userId == id);
      return;
    }

    final user = await _isar!.users.get(id);
    if (user?.isOwner == true) {
      throw StateError('Không thể xóa Chủ hội.');
    }

    final poolMembers = await _isar!.poolMembers.where().anyId().findAll();
    final paymentStatuses = await _isar!.paymentStatus
        .where()
        .anyId()
        .findAll();
    final winningRounds = await _isar!.rounds.where().anyId().findAll();
    final referencedPoolMembers = poolMembers
        .where((member) => member.userId == id)
        .toList(growable: false);
    final referencedPayments = paymentStatuses
        .where((payment) => payment.userId == id)
        .toList(growable: false);
    final referencedWins = winningRounds
        .where((round) => round.winnerId == id)
        .toList(growable: false);
    if (referencedPoolMembers.isNotEmpty ||
        referencedPayments.isNotEmpty ||
        referencedWins.isNotEmpty) {
      throw StateError(
        'Không thể xóa thành viên đã có trong lịch sử Phường hoặc lịch sử các kỳ.',
      );
    }

    await _isar!.writeTxn(() async {
      await _isar!.users.delete(id);
    });
  }

  Future<List<Pool>> getPools({String query = '', int? meetingDay}) async {
    List<Pool> pools;
    if (kIsWeb) {
      pools = List.from(_mockPools);
    } else {
      pools = await _isar!.pools.where().anyId().findAll();
    }

    // 1. Filter by meetingDay if provided
    if (meetingDay != null) {
      pools = pools.where((p) => p.meetingDay == meetingDay).toList();
    }

    // 2. Filter by search query if provided
    if (query.trim().isNotEmpty) {
      final normalized = query.toLowerCase();
      pools = pools
          .where((pool) => pool.name.toLowerCase().contains(normalized))
          .toList();
    }

    // 3. Sort final result
    pools.sort(_comparePools);
    return pools;
  }

  Future<Pool?> getPoolById(int id) async {
    if (kIsWeb) {
      return _mockPools.cast<Pool?>().firstWhere(
        (p) => p?.id == id,
        orElse: () => null,
      );
    }
    return _isar!.pools.get(id);
  }

  Future<Pool> savePool({
    int? id,
    required String name,
    required int baseAmount,
    required int totalRounds,
    required int meetingDay,
    required DateTime startDate,
    List<int> memberIds = const <int>[],
  }) async {
    final pool = Pool(
      id: id ?? (kIsWeb ? _getNextWebId() : Isar.autoIncrement),
      name: name.trim(),
      baseAmount: baseAmount,
      totalRounds: totalRounds,
      meetingDay: meetingDay,
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
    );
    final owner = kIsWeb
        ? _mockUsers.firstWhere((u) => u.isOwner)
        : (await _isar!.users.filter().isOwnerEqualTo(true).findFirst())!;

    var memberIdsToUse = memberIds.toSet().toList(growable: true);
    if (!memberIdsToUse.contains(owner.id)) {
      memberIdsToUse.add(owner.id);
    }

    if (kIsWeb) {
      final index = _mockPools.indexWhere((p) => p.id == pool.id);
      if (index >= 0) {
        _mockPools[index] = pool;
      } else {
        _mockPools.add(pool);
      }

      // Handle mock members and rounds
      if (memberIdsToUse.isNotEmpty) {
        _mockPoolMembers.removeWhere((m) => m.poolId == pool.id);
        _mockPoolMembers.addAll(
          memberIdsToUse.map(
            (userId) => PoolMember(
              id: _getNextWebId(),
              poolId: pool.id,
              userId: userId,
            ),
          ),
        );
      }

      if (id == null) {
        final rounds = _generateRoundsForPool(pool, ownerId: owner.id);
        for (final r in rounds) {
          r.id = _getNextWebId();
        }
        _mockRounds.addAll(rounds);
      }

      return pool;
    }

    await _isar!.writeTxn(() async {
      if (id == null && memberIds.isEmpty) {
        throw StateError('Phường phải có ít nhất một thành viên.');
      }

      if (id != null) {
        final existingPool = await _isar!.pools.get(id);
        if (existingPool == null) {
          throw StateError('Không tìm thấy Phường.');
        }

        final existingRounds = await _isar!.rounds
            .filter()
            .poolIdEqualTo(id)
            .findAll();
        final hasProcessedRounds = existingRounds.any(
          (round) =>
              round.winnerId != null ||
              round.bidAmount != 0 ||
              round.contributionAmount != 0 ||
              round.payoutAmount != 0 ||
              round.netReceiveAmount != 0,
        );
        final existingMembers = await _isar!.poolMembers
            .filter()
            .poolIdEqualTo(id)
            .findAll();
        final existingMemberIds = existingMembers
            .map((member) => member.userId)
            .toSet();
        final requestedMemberIds = memberIds.isEmpty
            ? existingMemberIds
            : memberIds.toSet();
        if (!requestedMemberIds.contains(owner.id))
          requestedMemberIds.add(owner.id);
        memberIdsToUse = requestedMemberIds.toList(growable: false);

        if (hasProcessedRounds) {
          final baseChanged = existingPool.baseAmount != pool.baseAmount;
          final roundsChanged = existingPool.totalRounds != pool.totalRounds;
          final meetingChanged = existingPool.meetingDay != pool.meetingDay;
          final dateChanged =
              existingPool.startDate.year != pool.startDate.year ||
              existingPool.startDate.month != pool.startDate.month ||
              existingPool.startDate.day != pool.startDate.day;
          final membersChanged =
              existingMemberIds.length != requestedMemberIds.length ||
              !existingMemberIds.containsAll(requestedMemberIds);

          if (baseChanged ||
              roundsChanged ||
              meetingChanged ||
              dateChanged ||
              membersChanged) {
            throw StateError('Phường đã có dữ liệu xử lý chỉ có thể đổi tên.');
          }
        } else {
          if (existingRounds.isNotEmpty) {
            final roundIds = existingRounds
                .map((round) => round.id)
                .toList(growable: false);
            final paymentStatuses = await _isar!.paymentStatus
                .filter()
                .anyOf(roundIds, (q, int id) => q.roundIdEqualTo(id))
                .findAll();
            if (paymentStatuses.isNotEmpty) {
              await _isar!.paymentStatus.deleteAll(
                paymentStatuses.map((item) => item.id).toList(growable: false),
              );
            }
            await _isar!.rounds.deleteAll(roundIds);
          }

          if (existingMembers.isNotEmpty) {
            await _isar!.poolMembers.deleteAll(
              existingMembers.map((item) => item.id).toList(growable: false),
            );
          }
        }
      }

      pool.id = await _isar!.pools.put(pool);

      if (memberIdsToUse.isNotEmpty) {
        final existingMembers = await _isar!.poolMembers
            .filter()
            .poolIdEqualTo(pool.id)
            .findAll();
        if (existingMembers.isNotEmpty) {
          await _isar!.poolMembers.deleteAll(
            existingMembers.map((member) => member.id).toList(growable: false),
          );
        }
        await _isar!.poolMembers.putAll(
          memberIdsToUse
              .map((userId) => PoolMember(poolId: pool.id, userId: userId))
              .toList(growable: false),
        );
      }

      if (id == null) {
        final rounds = _generateRoundsForPool(pool, ownerId: owner.id);
        final roundIds = await _isar!.rounds.putAll(rounds);
        for (var i = 0; i < rounds.length; i++) {
          rounds[i].id = roundIds[i];
        }
        await _ensurePaymentStatuses(pool.id, memberIdsToUse, rounds);
      } else {
        final rounds = await _isar!.rounds
            .filter()
            .poolIdEqualTo(pool.id)
            .findAll();
        if (rounds.isEmpty) {
          final regenerated = _generateRoundsForPool(pool, ownerId: owner.id);
          final regeneratedIds = await _isar!.rounds.putAll(regenerated);
          for (var i = 0; i < regenerated.length; i++) {
            regenerated[i].id = regeneratedIds[i];
          }
          await _ensurePaymentStatuses(pool.id, memberIdsToUse, regenerated);
        }
      }
    });

    return pool;
  }

  Future<void> deletePool(int id) async {
    if (kIsWeb) {
      _mockPools.removeWhere((p) => p.id == id);
      _mockPoolMembers.removeWhere((m) => m.poolId == id);
      _mockRounds.removeWhere((r) => r.poolId == id);
      _mockPaymentStatuses.removeWhere((ps) => ps.roundId == id); // Simple mock
      return;
    }

    await _isar!.writeTxn(() async {
      final rounds = await _isar!.rounds.filter().poolIdEqualTo(id).findAll();
      if (rounds.isNotEmpty) {
        final roundIds = rounds
            .map((round) => round.id)
            .toList(growable: false);
        final paymentStatuses = await _isar!.paymentStatus
            .filter()
            .anyOf(roundIds, (q, int id) => q.roundIdEqualTo(id))
            .findAll();
        if (paymentStatuses.isNotEmpty) {
          await _isar!.paymentStatus.deleteAll(
            paymentStatuses.map((item) => item.id).toList(growable: false),
          );
        }
        await _isar!.rounds.deleteAll(roundIds);
      }

      final members = await _isar!.poolMembers
          .filter()
          .poolIdEqualTo(id)
          .findAll();
      if (members.isNotEmpty) {
        await _isar!.poolMembers.deleteAll(
          members.map((member) => member.id).toList(growable: false),
        );
      }

      await _isar!.pools.delete(id);
    });
  }

  Future<List<User>> getPoolMembers(int poolId) async {
    if (kIsWeb) {
      final memberUserIds = _mockPoolMembers
          .where((m) => m.poolId == poolId)
          .map((m) => m.userId)
          .toSet();
      final users = _mockUsers
          .where((u) => memberUserIds.contains(u.id))
          .toList();
      users.sort(_compareUsers);
      return users;
    }

    final links = await _isar!.poolMembers
        .filter()
        .poolIdEqualTo(poolId)
        .findAll();
    final memberIds = links.map((link) => link.userId).toSet();
    final users = await _isar!.users.getAll(memberIds.toList());
    final result = users.whereType<User>().toList();
    result.sort(_compareUsers);
    return result;
  }

  Future<List<int>> getPoolMemberIds(int poolId) async {
    if (kIsWeb) {
      final ids = _mockPoolMembers
          .where((m) => m.poolId == poolId)
          .map((m) => m.userId)
          .toList();
      ids.sort();
      return ids;
    }

    final links = await _isar!.poolMembers
        .filter()
        .poolIdEqualTo(poolId)
        .findAll();
    final ids = links.map((link) => link.userId).toSet().toList();
    ids.sort();
    return ids;
  }

  Future<List<Pool>> getPoolsForUser(int userId) async {
    if (kIsWeb) {
      final poolIds = _mockPoolMembers
          .where((m) => m.userId == userId)
          .map((m) => m.poolId)
          .toSet();
      final pools = _mockPools.where((p) => poolIds.contains(p.id)).toList();
      pools.sort(_comparePools);
      return pools;
    }

    final links = await _isar!.poolMembers
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    final poolIds = links.map((link) => link.poolId).toSet();
    final pools = await _isar!.pools.getAll(poolIds.toList());
    final result = pools.whereType<Pool>().toList();
    result.sort(_comparePools);
    return result;
  }

  Future<Set<int>> getWinnerIdsForPool(int poolId) async {
    if (kIsWeb) {
      return _mockRounds
          .where((r) => r.poolId == poolId && r.winnerId != null)
          .map((r) => r.winnerId!)
          .toSet();
    }
    final rounds = await _isar!.rounds
        .filter()
        .poolIdEqualTo(poolId)
        .winnerIdIsNotNull()
        .findAll();
    return rounds.map((r) => r.winnerId!).toSet();
  }

  Future<List<Round>> getRoundsForPool(int poolId) async {
    if (kIsWeb) {
      final rounds = _mockRounds.where((r) => r.poolId == poolId).toList();
      rounds.sort((a, b) => a.roundNumber.compareTo(b.roundNumber));
      return rounds;
    }

    final rounds = await _isar!.rounds
        .filter()
        .poolIdEqualTo(poolId)
        .sortByRoundNumber()
        .findAll();
    return rounds;
  }

  Future<Set<int>> getWinnerPaidRoundIds(int poolId) async {
    if (kIsWeb) {
      final rounds = _mockRounds.where(
        (r) => r.poolId == poolId && r.winnerId != null,
      );
      final results = <int>{};
      for (final r in rounds) {
        final paid = _mockPaymentStatuses.any(
          (ps) => ps.roundId == r.id && ps.userId == r.winnerId && ps.isPaid,
        );
        if (paid) results.add(r.id);
      }
      return results;
    }

    final rounds = await _isar!.rounds
        .filter()
        .poolIdEqualTo(poolId)
        .winnerIdIsNotNull()
        .findAll();
    final roundIds = rounds.map((r) => r.id).toList();
    final statuses = await _isar!.paymentStatus
        .filter()
        .anyOf(roundIds, (q, int id) => q.roundIdEqualTo(id))
        .isPaidEqualTo(true)
        .findAll();

    final results = <int>{};
    final winnerMap = {for (final r in rounds) r.id: r.winnerId};
    for (final s in statuses) {
      if (s.userId == winnerMap[s.roundId]) {
        results.add(s.roundId);
      }
    }
    return results;
  }

  Future<Set<int>> getFullyPaidContributionRoundIds(int poolId) async {
    final members = await getPoolMembers(poolId);
    if (members.isEmpty) return <int>{};

    if (kIsWeb) {
      final rounds = _mockRounds.where((r) => r.poolId == poolId);
      final results = <int>{};
      for (final r in rounds) {
        final contributors = members.where((m) => m.id != r.winnerId);
        if (contributors.isEmpty) continue;
        final allPaid = contributors.every(
          (m) => _mockPaymentStatuses.any(
            (ps) => ps.roundId == r.id && ps.userId == m.id && ps.isPaid,
          ),
        );
        if (allPaid) results.add(r.id);
      }
      return results;
    }

    final rounds = await _isar!.rounds.filter().poolIdEqualTo(poolId).findAll();
    final roundIds = rounds.map((r) => r.id).toList();
    final allStatuses = await _isar!.paymentStatus
        .filter()
        .anyOf(roundIds, (q, int id) => q.roundIdEqualTo(id))
        .findAll();

    final results = <int>{};
    for (final r in rounds) {
      final contributors = members.where((m) => m.id != r.winnerId);
      if (contributors.isEmpty) continue;

      final roundStatuses = allStatuses
          .where((s) => s.roundId == r.id)
          .toList();
      final allPaid = contributors.every(
        (m) => roundStatuses.any((s) => s.userId == m.id && s.isPaid),
      );

      if (allPaid) results.add(r.id);
    }
    return results;
  }

  Future<Round?> getRoundById(int id) async {
    if (kIsWeb) {
      return _mockRounds.cast<Round?>().firstWhere(
        (r) => r?.id == id,
        orElse: () => null,
      );
    }
    return _isar!.rounds.get(id);
  }

  Future<Round> saveRoundResult({
    required int roundId,
    int? winnerId,
    required int bidAmount,
  }) async {
    if (kIsWeb) {
      final round = _mockRounds.cast<Round?>().firstWhere(
        (r) => r?.id == roundId,
        orElse: () => null,
      );
      if (round == null) throw StateError('Không tìm thấy kỳ.');

      final pool = _mockPools.cast<Pool?>().firstWhere(
        (p) => p?.id == round.poolId,
        orElse: () => null,
      );
      if (pool == null) throw StateError('Không tìm thấy Phường.');

      if (round.roundNumber == 1) {
        throw StateError(
          'Kỳ 1 là kỳ mặc định của Chủ hội, không thể thay đổi.',
        );
      }

      if (winnerId == null) {
        round
          ..winnerId = null
          ..bidAmount = 0
          ..payoutAmount = 0
          ..contributionAmount = 0
          ..netReceiveAmount = 0;
      } else {
        final memberIds = await getPoolMemberIds(pool.id);
        if (!memberIds.contains(winnerId)) {
          throw StateError('Người lấy phải là thành viên của Phường.');
        }

        final calculation = FinancialCalculator.calculate(
          memberCount: memberIds.length,
          baseAmount: pool.baseAmount,
          bidAmount: bidAmount,
        );

        round
          ..winnerId = winnerId
          ..bidAmount = calculation.bidAmount
          ..payoutAmount = calculation.payoutAmount
          ..contributionAmount = calculation.contributionAmount
          ..netReceiveAmount = calculation.netReceiveAmount;
      }

      return round;
    }

    final round = await _isar!.rounds.get(roundId);
    if (round == null) throw StateError('Không tìm thấy kỳ.');

    final pool = await _isar!.pools.get(round.poolId);
    if (pool == null) throw StateError('Không tìm thấy Phường.');

    if (round.roundNumber == 1) {
      throw StateError('Kỳ 1 là kỳ mặc định của Chủ hội, không thể thay đổi.');
    }

    final memberIds = await getPoolMemberIds(pool.id);

    if (winnerId == null) {
      round
        ..winnerId = null
        ..bidAmount = 0
        ..payoutAmount = 0
        ..contributionAmount = 0
        ..netReceiveAmount = 0;
    } else {
      if (!memberIds.contains(winnerId)) {
        throw StateError(
          'Người lấy ($winnerId) phải là thành viên của Phường (Pool: ${pool.id}, Members: $memberIds).',
        );
      }

      final priorWinningRounds = await _isar!.rounds
          .filter()
          .poolIdEqualTo(pool.id)
          .winnerIdEqualTo(winnerId)
          .not()
          .idEqualTo(roundId)
          .findAll();

      if (priorWinningRounds.isNotEmpty) {
        throw StateError(
          'Thành viên này đã lấy một kỳ khác trong cùng Phường.',
        );
      }

      final calculation = FinancialCalculator.calculate(
        memberCount: memberIds.length,
        baseAmount: pool.baseAmount,
        bidAmount: bidAmount,
      );

      round
        ..winnerId = winnerId
        ..bidAmount = calculation.bidAmount
        ..payoutAmount = calculation.payoutAmount
        ..contributionAmount = calculation.contributionAmount
        ..netReceiveAmount = calculation.netReceiveAmount;
    }

    await _isar!.writeTxn(() async {
      await _isar!.rounds.put(round);
      await _ensurePaymentStatuses(pool.id, memberIds, [round]);
    });

    return round;
  }

  Future<List<PaymentStatus>> getPaymentStatusesForRound(int roundId) async {
    if (kIsWeb) {
      final statuses = _mockPaymentStatuses
          .where((ps) => ps.roundId == roundId)
          .toList();
      statuses.sort((a, b) => a.userId.compareTo(b.userId));
      return statuses;
    }
    final statuses = await _isar!.paymentStatus
        .filter()
        .roundIdEqualTo(roundId)
        .findAll();
    statuses.sort((a, b) => a.userId.compareTo(b.userId));
    return statuses;
  }

  Future<void> setPaymentStatus({
    required int userId,
    required int roundId,
    required bool isPaid,
    int? amountToAdd,
    String? note,
  }) async {
    if (kIsWeb) {
      final index = _mockPaymentStatuses.indexWhere(
        (ps) => ps.userId == userId && ps.roundId == roundId,
      );
      final entry = PaymentEntry(
        amount: amountToAdd,
        date: DateTime.now(),
        note: note,
      );

      if (index >= 0) {
        final ps = _mockPaymentStatuses[index];
        ps.isPaid = isPaid;
        if (amountToAdd != null) {
          ps.history ??= [];
          ps.history!.add(entry);
        }
      } else {
        _mockPaymentStatuses.add(
          PaymentStatus(
            id: _getNextWebId(),
            userId: userId,
            roundId: roundId,
            isPaid: isPaid,
            history: amountToAdd != null ? [entry] : [],
          ),
        );
      }
      return;
    }
    PaymentStatus? existing;
    for (final item in await _isar!.paymentStatus.where().anyId().findAll()) {
      if (item.userId == userId && item.roundId == roundId) {
        existing = item;
        break;
      }
    }
    final status =
        existing ??
        PaymentStatus(userId: userId, roundId: roundId, isPaid: isPaid);
    status.isPaid = isPaid;
    if (amountToAdd != null) {
      status.history ??= [];
      status.history!.add(
        PaymentEntry(amount: amountToAdd, date: DateTime.now(), note: note),
      );
    }
    await _isar!.writeTxn(() async {
      await _isar!.paymentStatus.put(status);
    });
  }

  Future<List<UserMonthlyStatement>> buildMonthlyStatement({
    required int month,
    required int year,
    String query = '',
  }) async {
    final users = await getUsers(query: query);
    List<Pool> pools;
    List<PoolMember> poolMembers;
    List<Round> rounds;

    if (kIsWeb) {
      pools = List.from(_mockPools);
      poolMembers = List.from(_mockPoolMembers);
      rounds = List.from(_mockRounds);
    } else {
      pools = await _isar!.pools.where().anyId().findAll();
      poolMembers = await _isar!.poolMembers.where().anyId().findAll();
      rounds = await _isar!.rounds.where().anyId().findAll();
    }

    List<PaymentStatus> paymentStatuses;
    if (kIsWeb) {
      paymentStatuses = List.from(_mockPaymentStatuses);
    } else {
      paymentStatuses = await _isar!.paymentStatus.where().anyId().findAll();
    }
    final paymentMap = {
      for (final ps in paymentStatuses) '${ps.userId}_${ps.roundId}': ps,
    };

    final poolsById = {for (final pool in pools) pool.id: pool};
    final roundsByPool = <int, List<Round>>{};
    for (final round in rounds) {
      if (!_matchesMonth(round.date, month, year)) {
        continue;
      }
      roundsByPool.putIfAbsent(round.poolId, () => <Round>[]).add(round);
    }

    final memberPools = <int, Set<int>>{};
    for (final member in poolMembers) {
      memberPools.putIfAbsent(member.userId, () => <int>{}).add(member.poolId);
    }

    final statements = <UserMonthlyStatement>[];
    for (final user in users) {
      final breakdownMap = <int, PoolStatementBreakdown>{};
      var totalPay = 0;
      var totalReceive = 0;

      final poolIds = memberPools[user.id] ?? <int>{};
      for (final poolId in poolIds) {
        final pool = poolsById[poolId];
        if (pool == null) {
          continue;
        }
        final monthlyRounds = roundsByPool[poolId] ?? const <Round>[];
        if (monthlyRounds.isEmpty) {
          continue;
        }

        int payAmount = 0;
        int receiveAmount = 0;
        final roundNumbers = <int>[];
        final roundIds = <int>[];
        final roundDates = <DateTime>[];
        bool isPaid = false;
        int actualAmount = 0;
        final notes = <String>[];

        final historyEntries = <StatementPaymentEntry>[];
        for (final round in monthlyRounds) {
          final ps = paymentMap['${user.id}_${round.id}'];
          int expectedForRound = 0;
          if (round.winnerId == user.id) {
            expectedForRound = round.netReceiveAmount;
            receiveAmount += expectedForRound;
            roundNumbers.add(round.roundNumber);
            roundIds.add(round.id);
            roundDates.add(round.date);
          } else if (round.winnerId != null) {
            expectedForRound = -round.contributionAmount;
            payAmount += round.contributionAmount;
            roundNumbers.add(round.roundNumber);
            roundIds.add(round.id);
            roundDates.add(round.date);
          }

          if (ps != null) {
            if (ps.isPaid) isPaid = true;
            actualAmount += ps.totalActualAmount;
            if (ps.history != null) {
              for (final entry in ps.history!) {
                if (entry.note != null && entry.note!.trim().isNotEmpty) {
                  notes.add(entry.note!.trim());
                }
                historyEntries.add(StatementPaymentEntry(
                  amount: entry.amount ?? 0,
                  date: entry.date ?? DateTime.now(),
                  note: entry.note,
                ));
              }
            }
            if (actualAmount == 0 && ps.isPaid) {
              actualAmount = expectedForRound;
            }
          }
        }

        if (payAmount == 0 && receiveAmount == 0) {
          continue;
        }

        totalPay += payAmount;
        totalReceive += receiveAmount;

        breakdownMap[poolId] = PoolStatementBreakdown(
          poolId: poolId,
          poolName: pool.name,
          roundNumbers: roundNumbers,
          roundIds: roundIds,
          roundDates: roundDates,
          payAmount: payAmount,
          receiveAmount: receiveAmount,
          actualAmount: actualAmount,
          notes: notes,
          history: historyEntries,
        );
      }

      if (breakdownMap.isNotEmpty) {
        statements.add(
          UserMonthlyStatement(
            userId: user.id,
            userName: user.name,
            phone: user.phone,
            totalPay: totalPay,
            totalReceive: totalReceive,
            breakdowns: breakdownMap.values.toList(growable: false)
              ..sort((a, b) => a.poolName.compareTo(b.poolName)),
          ),
        );
      }
    }

    return statements;
  }

  Future<List<StatementRoundOption>> getStatementRoundOptions({
    required int month,
    required int year,
  }) async {
    List<Pool> pools;
    List<Round> rounds;

    if (kIsWeb) {
      pools = List.from(_mockPools);
      rounds = List.from(_mockRounds);
    } else {
      pools = await _isar!.pools.where().anyId().findAll();
      rounds = await _isar!.rounds.where().anyId().findAll();
    }

    final poolsById = {for (final pool in pools) pool.id: pool};
    final options = <StatementRoundOption>[];

    for (final round in rounds) {
      if (!_matchesMonth(round.date, month, year)) continue;
      final pool = poolsById[round.poolId];
      if (pool == null) continue;

      options.add(
        StatementRoundOption(
          roundId: round.id,
          poolId: pool.id,
          poolName: pool.name,
          poolStartDate: pool.startDate,
          roundNumber: round.roundNumber,
          date: round.date,
        ),
      );
    }

    options.sort((left, right) {
      final dateCompare = left.date.compareTo(right.date);
      if (dateCompare != 0) return dateCompare;
      final poolCompare = left.poolName.compareTo(right.poolName);
      if (poolCompare != 0) return poolCompare;
      return left.roundNumber.compareTo(right.roundNumber);
    });

    return options;
  }

  Future<List<UserMonthlyStatement>> buildStatementForRoundIds({
    required Set<int> roundIds,
    String query = '',
  }) async {
    if (roundIds.isEmpty) return <UserMonthlyStatement>[];

    final users = await getUsers(query: query);
    List<Pool> pools;
    List<PoolMember> poolMembers;
    List<Round> rounds;

    if (kIsWeb) {
      pools = List.from(_mockPools);
      poolMembers = List.from(_mockPoolMembers);
      rounds = List.from(_mockRounds);
    } else {
      pools = await _isar!.pools.where().anyId().findAll();
      poolMembers = await _isar!.poolMembers.where().anyId().findAll();
      rounds = await _isar!.rounds.where().anyId().findAll();
    }

    List<PaymentStatus> paymentStatuses;
    if (kIsWeb) {
      paymentStatuses = List.from(_mockPaymentStatuses);
    } else {
      paymentStatuses = await _isar!.paymentStatus.where().anyId().findAll();
    }
    final paymentMap = {
      for (final ps in paymentStatuses) '${ps.userId}_${ps.roundId}': ps,
    };

    final poolsById = {for (final pool in pools) pool.id: pool};
    final selectedRoundsByPool = <int, List<Round>>{};
    final selectedRoundSet = roundIds.toSet();
    for (final round in rounds) {
      if (!selectedRoundSet.contains(round.id)) continue;
      selectedRoundsByPool
          .putIfAbsent(round.poolId, () => <Round>[])
          .add(round);
    }

    final memberPools = <int, Set<int>>{};
    for (final member in poolMembers) {
      memberPools.putIfAbsent(member.userId, () => <int>{}).add(member.poolId);
    }

    final statements = <UserMonthlyStatement>[];
    for (final user in users) {
      final breakdownMap = <int, PoolStatementBreakdown>{};
      var totalPay = 0;
      var totalReceive = 0;

      final poolIds = memberPools[user.id] ?? <int>{};
      for (final poolId in poolIds) {
        final pool = poolsById[poolId];
        if (pool == null) continue;

        final selectedRounds = selectedRoundsByPool[poolId] ?? const <Round>[];
        if (selectedRounds.isEmpty) continue;

        int payAmount = 0;
        int receiveAmount = 0;
        final roundNumbers = <int>[];
        final roundIdsForPool = <int>[];
        final roundDates = <DateTime>[];
        bool isPaid = false;
        int actualAmount = 0;
        final notes = <String>[];

        final historyEntries = <StatementPaymentEntry>[];
        for (final round in selectedRounds) {
          final ps = paymentMap['${user.id}_${round.id}'];
          int expectedForRound = 0;
          if (round.winnerId == user.id) {
            expectedForRound = round.netReceiveAmount;
            receiveAmount += expectedForRound;
            roundNumbers.add(round.roundNumber);
            roundIdsForPool.add(round.id);
            roundDates.add(round.date);
          } else if (round.winnerId != null) {
            expectedForRound = -round.contributionAmount;
            payAmount += round.contributionAmount;
            roundNumbers.add(round.roundNumber);
            roundIdsForPool.add(round.id);
            roundDates.add(round.date);
          }

          if (ps != null) {
            if (ps.isPaid) isPaid = true;
            actualAmount += ps.totalActualAmount;
            if (ps.history != null) {
              for (final entry in ps.history!) {
                if (entry.note != null && entry.note!.trim().isNotEmpty) {
                  notes.add(entry.note!.trim());
                }
                historyEntries.add(StatementPaymentEntry(
                  amount: entry.amount ?? 0,
                  date: entry.date ?? DateTime.now(),
                  note: entry.note,
                ));
              }
            }
            if (actualAmount == 0 && ps.isPaid) {
              actualAmount = expectedForRound;
            }
          }
        }

        totalPay += payAmount;
        totalReceive += receiveAmount;

        breakdownMap[poolId] = PoolStatementBreakdown(
          poolId: poolId,
          poolName: pool.name,
          roundNumbers: roundNumbers,
          roundIds: roundIdsForPool,
          roundDates: roundDates,
          payAmount: payAmount,
          receiveAmount: receiveAmount,
          actualAmount: actualAmount,
          notes: notes,
          history: historyEntries,
        );
      }

      if (breakdownMap.isNotEmpty) {
        statements.add(
          UserMonthlyStatement(
            userId: user.id,
            userName: user.name,
            phone: user.phone,
            totalPay: totalPay,
            totalReceive: totalReceive,
            breakdowns: breakdownMap.values.toList(growable: false)
              ..sort((a, b) => a.poolName.compareTo(b.poolName)),
          ),
        );
      }
    }

    return statements;
  }

  /// Build statement for a date range (from startDate to endDate inclusive).
  /// This is useful for ad-hoc collection periods that don't follow lunar months.
  Future<List<UserMonthlyStatement>> buildStatementByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String query = '',
  }) async {
    final users = await getUsers(query: query);
    List<Pool> pools;
    List<PoolMember> poolMembers;
    List<Round> rounds;

    if (kIsWeb) {
      pools = List.from(_mockPools);
      poolMembers = List.from(_mockPoolMembers);
      rounds = List.from(_mockRounds);
    } else {
      pools = await _isar!.pools.where().anyId().findAll();
      poolMembers = await _isar!.poolMembers.where().anyId().findAll();
      rounds = await _isar!.rounds.where().anyId().findAll();
    }

    List<PaymentStatus> paymentStatuses;
    if (kIsWeb) {
      paymentStatuses = List.from(_mockPaymentStatuses);
    } else {
      paymentStatuses = await _isar!.paymentStatus.where().anyId().findAll();
    }
    final paymentMap = {
      for (final ps in paymentStatuses) '${ps.userId}_${ps.roundId}': ps,
    };

    final poolsById = {for (final pool in pools) pool.id: pool};
    final roundsByPool = <int, List<Round>>{};

    // Filter rounds by date range (inclusive)
    for (final round in rounds) {
      if (round.date.isBefore(startDate) || round.date.isAfter(endDate)) {
        continue;
      }
      roundsByPool.putIfAbsent(round.poolId, () => <Round>[]).add(round);
    }

    final memberPools = <int, Set<int>>{};
    for (final member in poolMembers) {
      memberPools.putIfAbsent(member.userId, () => <int>{}).add(member.poolId);
    }

    final statements = <UserMonthlyStatement>[];
    for (final user in users) {
      final breakdownMap = <int, PoolStatementBreakdown>{};
      var totalPay = 0;
      var totalReceive = 0;

      final poolIds = memberPools[user.id] ?? <int>{};
      for (final poolId in poolIds) {
        final pool = poolsById[poolId];
        if (pool == null) {
          continue;
        }
        final periodRounds = roundsByPool[poolId] ?? const <Round>[];
        if (periodRounds.isEmpty) {
          continue;
        }

        int payAmount = 0;
        int receiveAmount = 0;
        int actualAmount = 0;
        final notes = <String>[];
        final roundNumbers = <int>[];
        final roundIds = <int>[];
        final roundDates = <DateTime>[];
        bool isPaid = false;

        final historyEntries = <StatementPaymentEntry>[];
        for (final round in periodRounds) {
          final ps = paymentMap['${user.id}_${round.id}'];
          int expectedForRound = 0;
          if (round.winnerId == user.id) {
            expectedForRound = round.netReceiveAmount;
            receiveAmount += expectedForRound;
            roundNumbers.add(round.roundNumber);
            roundIds.add(round.id);
            roundDates.add(round.date);
          } else if (round.winnerId != null) {
            expectedForRound = -round.contributionAmount;
            payAmount += round.contributionAmount;
            roundNumbers.add(round.roundNumber);
            roundIds.add(round.id);
            roundDates.add(round.date);
          }

          if (ps != null) {
            if (ps.isPaid) isPaid = true;
            actualAmount += ps.totalActualAmount;
            if (ps.history != null) {
              for (final entry in ps.history!) {
                if (entry.note != null && entry.note!.trim().isNotEmpty) {
                  notes.add(entry.note!.trim());
                }
                historyEntries.add(StatementPaymentEntry(
                  amount: entry.amount ?? 0,
                  date: entry.date ?? DateTime.now(),
                  note: entry.note,
                ));
              }
            }
            if (actualAmount == 0 && ps.isPaid) {
              actualAmount = expectedForRound;
            }
          }
        }

        if (payAmount == 0 && receiveAmount == 0) {
          continue;
        }

        totalPay += payAmount;
        totalReceive += receiveAmount;

        breakdownMap[poolId] = PoolStatementBreakdown(
          poolId: poolId,
          poolName: pool.name,
          roundNumbers: roundNumbers,
          roundIds: roundIds,
          roundDates: roundDates,
          payAmount: payAmount,
          receiveAmount: receiveAmount,
          actualAmount: actualAmount,
          notes: notes,
          history: historyEntries,
        );
      }

      if (breakdownMap.isNotEmpty) {
        statements.add(
          UserMonthlyStatement(
            userId: user.id,
            userName: user.name,
            phone: user.phone,
            totalPay: totalPay,
            totalReceive: totalReceive,
            breakdowns: breakdownMap.values.toList(growable: false)
              ..sort((a, b) => a.poolName.compareTo(b.poolName)),
          ),
        );
      }
    }

    return statements;
  }

  Future<BackupSnapshot> exportSnapshot() async {
    if (kIsWeb) {
      return BackupSnapshot(
        users: _mockUsers.map(_userToMap).toList(growable: false),
        pools: _mockPools.map(_poolToMap).toList(growable: false),
        poolMembers: _mockPoolMembers
            .map(_poolMemberToMap)
            .toList(growable: false),
        rounds: _mockRounds.map(_roundToMap).toList(growable: false),
        paymentStatuses: _mockPaymentStatuses
            .map(_paymentStatusToMap)
            .toList(growable: false),
      );
    }
    final users = await _isar!.users.where().anyId().findAll();
    final pools = await _isar!.pools.where().anyId().findAll();
    final poolMembers = await _isar!.poolMembers.where().anyId().findAll();
    final rounds = await _isar!.rounds.where().anyId().findAll();
    final paymentStatuses = await _isar!.paymentStatus
        .where()
        .anyId()
        .findAll();

    return BackupSnapshot(
      users: users.map(_userToMap).toList(growable: false),
      pools: pools.map(_poolToMap).toList(growable: false),
      poolMembers: poolMembers.map(_poolMemberToMap).toList(growable: false),
      rounds: rounds.map(_roundToMap).toList(growable: false),
      paymentStatuses: paymentStatuses
          .map(_paymentStatusToMap)
          .toList(growable: false),
    );
  }

  Future<void> importSnapshot(BackupSnapshot snapshot) async {
    await clearAll();

    if (kIsWeb) {
      _mockUsers.addAll(snapshot.users.map(_userFromMap));
      _mockPools.addAll(snapshot.pools.map(_poolFromMap));
      _mockPoolMembers.addAll(snapshot.poolMembers.map(_poolMemberFromMap));
      _mockRounds.addAll(snapshot.rounds.map(_roundFromMap));
      _mockPaymentStatuses.addAll(
        snapshot.paymentStatuses.map(_paymentStatusFromMap),
      );
      return;
    }

    await _isar!.writeTxn(() async {
      await _isar!.users.putAll(
        snapshot.users.map(_userFromMap).toList(growable: false),
      );
      await _isar!.pools.putAll(
        snapshot.pools.map(_poolFromMap).toList(growable: false),
      );
      await _isar!.poolMembers.putAll(
        snapshot.poolMembers.map(_poolMemberFromMap).toList(growable: false),
      );
      await _isar!.rounds.putAll(
        snapshot.rounds.map(_roundFromMap).toList(growable: false),
      );
      await _isar!.paymentStatus.putAll(
        snapshot.paymentStatuses
            .map(_paymentStatusFromMap)
            .toList(growable: false),
      );
    });
  }

  Future<File> exportSnapshotToFile(
    BackupSnapshot snapshot, {
    String? fileNamePrefix,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Lưu file trực tiếp không được hỗ trợ trên Web. Vui lòng sử dụng tính năng tải xuống.',
      );
    }
    final directory = await getApplicationDocumentsDirectory();
    final exportDirectory = Directory('${directory.path}/hop_phuong_exports');
    if (!await exportDirectory.exists()) {
      await exportDirectory.create(recursive: true);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final prefix = fileNamePrefix ?? 'hop_phuong_backup';
    final file = File('${exportDirectory.path}/${prefix}_$timestamp.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(snapshot.toJson()),
    );
    return file;
  }

  Future<File> exportStringToFile(
    String content, {
    required String fileName,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Lưu file trực tiếp không được hỗ trợ trên Web. Vui lòng sử dụng tính năng tải xuống.',
      );
    }
    final directory = await getApplicationDocumentsDirectory();
    final exportDirectory = Directory('${directory.path}/hop_phuong_exports');
    if (!await exportDirectory.exists()) {
      await exportDirectory.create(recursive: true);
    }

    final file = File('${exportDirectory.path}/$fileName');
    await file.writeAsString(content);
    return file;
  }

  List<Round> _generateRoundsForPool(Pool pool, {int? ownerId}) {
    final dates = _lunarScheduleService.generateMeetingDates(
      startDate: pool.startDate,
      totalRounds: pool.totalRounds,
      meetingDay: pool.meetingDay,
    );

    return List<Round>.generate(dates.length, (index) {
      final roundNumber = index + 1;
      final round = Round(
        poolId: pool.id,
        roundNumber: roundNumber,
        date: dates[index],
      );

      if (roundNumber == 1 && ownerId != null) {
        round.winnerId = ownerId;
        round.bidAmount = 0;
        round.contributionAmount = pool.baseAmount;
        round.payoutAmount = pool.baseAmount;
        round.netReceiveAmount = pool.baseAmount;
      }

      return round;
    }, growable: false);
  }

  Future<void> _ensurePaymentStatuses(
    int poolId,
    List<int> memberIds,
    List<Round> rounds,
  ) async {
    if (memberIds.isEmpty || rounds.isEmpty) {
      return;
    }

    if (kIsWeb) {
      // Mock payment statuses for rounds
      for (final round in rounds) {
        for (final userId in memberIds) {
          final exists = _mockPaymentStatuses.any(
            (ps) => ps.roundId == round.id && ps.userId == userId,
          );
          if (!exists) {
            _mockPaymentStatuses.add(
              PaymentStatus(
                id: _getNextWebId(),
                userId: userId,
                roundId: round.id,
                isPaid: false,
              ),
            );
          }
        }
      }
      return;
    }

    final existing = await _isar!.paymentStatus
        .filter()
        .anyOf(
          rounds.map((r) => r.id).toList(),
          (q, int id) => q.roundIdEqualTo(id),
        )
        .findAll();
    final existingKeys = existing
        .map((status) => '${status.roundId}:${status.userId}')
        .toSet();
    final toInsert = <PaymentStatus>[];

    for (final round in rounds) {
      for (final userId in memberIds) {
        final key = '${round.id}:$userId';
        if (!existingKeys.contains(key)) {
          toInsert.add(
            PaymentStatus(userId: userId, roundId: round.id, isPaid: false),
          );
        }
      }
    }

    if (toInsert.isNotEmpty) {
      await _isar!.paymentStatus.putAll(toInsert);
    }
  }

  Map<String, dynamic> _userToMap(User user) => {
    'id': user.id,
    'name': user.name,
    'phone': user.phone,
    'isOwner': user.isOwner,
  };

  User _userFromMap(Map<String, dynamic> json) => User(
    id: (json['id'] as num?)?.toInt() ?? Isar.autoIncrement,
    name: (json['name'] ?? '').toString(),
    phone: (json['phone'] ?? '').toString(),
    isOwner: json['isOwner'] == true,
  );

  Map<String, dynamic> _poolToMap(Pool pool) => {
    'id': pool.id,
    'name': pool.name,
    'baseAmount': pool.baseAmount,
    'totalRounds': pool.totalRounds,
    'meetingDay': pool.meetingDay,
    'startDate': pool.startDate.toIso8601String(),
  };

  Pool _poolFromMap(Map<String, dynamic> json) => Pool(
    id: (json['id'] as num?)?.toInt() ?? Isar.autoIncrement,
    name: (json['name'] ?? '').toString(),
    baseAmount: (json['baseAmount'] as num?)?.toInt() ?? 0,
    totalRounds: (json['totalRounds'] as num?)?.toInt() ?? 0,
    meetingDay: (json['meetingDay'] as num?)?.toInt() ?? 1,
    startDate: DateTime.parse(
      (json['startDate'] ?? DateTime.now().toIso8601String()).toString(),
    ),
  );

  Map<String, dynamic> _poolMemberToMap(PoolMember item) => {
    'id': item.id,
    'poolId': item.poolId,
    'userId': item.userId,
  };

  PoolMember _poolMemberFromMap(Map<String, dynamic> json) => PoolMember(
    id: (json['id'] as num?)?.toInt() ?? Isar.autoIncrement,
    poolId: (json['poolId'] as num?)?.toInt() ?? 0,
    userId: (json['userId'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> _roundToMap(Round round) => {
    'id': round.id,
    'poolId': round.poolId,
    'roundNumber': round.roundNumber,
    'date': round.date.toIso8601String(),
    'winnerId': round.winnerId,
    'bidAmount': round.bidAmount,
    'contributionAmount': round.contributionAmount,
    'payoutAmount': round.payoutAmount,
    'netReceiveAmount': round.netReceiveAmount,
  };

  Round _roundFromMap(Map<String, dynamic> json) => Round(
    id: (json['id'] as num?)?.toInt() ?? Isar.autoIncrement,
    poolId: (json['poolId'] as num?)?.toInt() ?? 0,
    roundNumber: (json['roundNumber'] as num?)?.toInt() ?? 1,
    date: DateTime.parse(
      (json['date'] ?? DateTime.now().toIso8601String()).toString(),
    ),
    winnerId: (json['winnerId'] as num?)?.toInt(),
    bidAmount: (json['bidAmount'] as num?)?.toInt() ?? 0,
    contributionAmount: (json['contributionAmount'] as num?)?.toInt() ?? 0,
    payoutAmount: (json['payoutAmount'] as num?)?.toInt() ?? 0,
    netReceiveAmount: (json['netReceiveAmount'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> _paymentStatusToMap(PaymentStatus item) => {
    'id': item.id,
    'userId': item.userId,
    'roundId': item.roundId,
    'isPaid': item.isPaid,
  };

  PaymentStatus _paymentStatusFromMap(Map<String, dynamic> json) =>
      PaymentStatus(
        id: (json['id'] as num?)?.toInt() ?? Isar.autoIncrement,
        userId: (json['userId'] as num?)?.toInt() ?? 0,
        roundId: (json['roundId'] as num?)?.toInt() ?? 0,
        isPaid: json['isPaid'] == true,
      );

  bool _matchesMonth(DateTime date, int month, int year) {
    final lunar = LunarCalendar.solarToLunar(date);
    return lunar.year == year && lunar.month == month;
  }

  int _compareUsers(User left, User right) {
    if (left.isOwner != right.isOwner) {
      return left.isOwner ? -1 : 1;
    }
    final nameCompare = left.name.toLowerCase().compareTo(
      right.name.toLowerCase(),
    );
    if (nameCompare != 0) {
      return nameCompare;
    }
    return left.id.compareTo(right.id);
  }

  int _comparePools(Pool left, Pool right) {
    final nameCompare = left.name.toLowerCase().compareTo(
      right.name.toLowerCase(),
    );
    if (nameCompare != 0) {
      return nameCompare;
    }
    return left.id.compareTo(right.id);
  }
}
