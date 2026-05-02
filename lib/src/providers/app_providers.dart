import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunar_calendar/lunar_calendar.dart';

import '../data/app_repository.dart';
import '../models/pool_entity.dart';
import '../models/round_entity.dart';
import '../models/statement_models.dart';
import '../models/user_entity.dart';
import '../services/sample_data_service.dart';

final appRepositoryProvider = FutureProvider<AppRepository>((ref) async {
  final repository = await AppRepository.open();
  await const SampleDataService().seedIfEmpty(repository);
  return repository;
});

final selectedTabProvider = StateProvider<int>((ref) => 0);
final memberSearchProvider = StateProvider<String>((ref) => '');
final poolSearchProvider = StateProvider<String>((ref) => '');
final roundSearchProvider = StateProvider<String>((ref) => '');
final statementSearchProvider = StateProvider<String>((ref) => '');
final selectedPoolIdProvider = StateProvider<int?>((ref) => null);
final statementMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  final lunar = LunarCalendar.solarToLunar(now);
  return DateTime(lunar.year, lunar.month);
});

final membersProvider = FutureProvider<List<User>>((ref) async {
  final repository = await ref.watch(appRepositoryProvider.future);
  final query = ref.watch(memberSearchProvider);
  return repository.getUsers(query: query);
});

final poolsProvider = FutureProvider<List<Pool>>((ref) async {
  final repository = await ref.watch(appRepositoryProvider.future);
  final query = ref.watch(poolSearchProvider);
  return repository.getPools(query: query);
});

final selectedPoolMembersProvider = FutureProvider<List<User>>((ref) async {
  final repository = await ref.watch(appRepositoryProvider.future);
  final poolId = ref.watch(selectedPoolIdProvider);
  if (poolId == null) {
    return <User>[];
  }
  return repository.getPoolMembers(poolId);
});

final roundsProvider = FutureProvider<List<Round>>((ref) async {
  final repository = await ref.watch(appRepositoryProvider.future);
  final poolId = ref.watch(selectedPoolIdProvider);
  if (poolId == null) {
    return <Round>[];
  }
  final query = ref.watch(roundSearchProvider).trim().toLowerCase();
  final rounds = await repository.getRoundsForPool(poolId);
  if (query.isEmpty) {
    return rounds;
  }
  return rounds.where((round) => round.roundNumber.toString().contains(query) || round.bidAmount.toString().contains(query)).toList(growable: false);
});

final statementProvider = FutureProvider<List<UserMonthlyStatement>>((ref) async {
  final repository = await ref.watch(appRepositoryProvider.future);
  final filter = ref.watch(statementMonthProvider);
  final query = ref.watch(statementSearchProvider);
  return repository.buildMonthlyStatement(month: filter.month, year: filter.year, query: query);
});
