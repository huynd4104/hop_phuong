import 'package:hop_phuong/src/utils/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lunar_calendar/lunar_calendar.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:hop_phuong/src/data/app_repository.dart';
import 'package:hop_phuong/src/models/user_entity.dart';
import 'package:hop_phuong/src/models/pool_entity.dart';
import 'package:hop_phuong/src/models/pool_member_entity.dart';
import 'package:hop_phuong/src/models/round_entity.dart';
import 'package:hop_phuong/src/models/payment_status_entity.dart';
import 'package:hop_phuong/src/models/statement_models.dart';
import 'package:hop_phuong/src/providers/app_providers.dart';
import 'package:hop_phuong/src/services/backup_service.dart';
import 'package:hop_phuong/src/services/financial_calculator.dart';
import 'package:hop_phuong/src/services/lunar_schedule_service.dart';
import 'package:hop_phuong/src/services/statement_export_service.dart';
import 'package:hop_phuong/src/utils/formatters.dart';

// UI Imports (nếu cần)
import 'package:hop_phuong/src/ui/screens/home_shell.dart';
import 'package:hop_phuong/src/ui/screens/members_screen.dart';
import 'package:hop_phuong/src/ui/screens/pools_screen.dart';
import 'package:hop_phuong/src/ui/screens/rounds_screen.dart';
import 'package:hop_phuong/src/ui/screens/statement_screen.dart';
import 'package:hop_phuong/src/ui/screens/backup_screen.dart';
import 'package:hop_phuong/src/ui/widgets/side_nav.dart';
import 'package:hop_phuong/src/ui/widgets/info_card.dart';
import 'package:hop_phuong/src/ui/widgets/feature_card.dart';
import 'package:hop_phuong/src/ui/widgets/mini_chip.dart';
import 'package:hop_phuong/src/ui/widgets/pool_header_card.dart';
import 'package:hop_phuong/src/ui/widgets/empty_state.dart';
import 'package:hop_phuong/src/ui/widgets/error_view.dart';
import 'package:hop_phuong/src/ui/widgets/date_info_card.dart';
import 'package:hop_phuong/src/ui/dialogs/user_dialog.dart';
import 'package:hop_phuong/src/ui/dialogs/pool_dialog.dart';
import 'package:hop_phuong/src/ui/dialogs/round_dialog.dart';
import 'package:hop_phuong/src/ui/dialogs/pool_members_dialog.dart';
import 'package:hop_phuong/src/models/statement_totals.dart';

class PoolsScreen extends ConsumerStatefulWidget {
  const PoolsScreen({super.key});

  @override
  ConsumerState<PoolsScreen> createState() => _PoolsScreenState();
}

class _PoolsScreenState extends ConsumerState<PoolsScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final poolsAsync = ref.watch(poolsProvider);
    final query = ref.watch(poolSearchProvider);
    final filterDay = ref.watch(poolFilterDayProvider);
    final cs = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        8,
        isMobile ? 16 : 24,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm Phường theo tên…',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: cs.onSurfaceVariant,
                    ),
                    hintStyle: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  onChanged: (v) =>
                      ref.read(poolSearchProvider.notifier).state = v,
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterButton(context, ref, filterDay),
              const SizedBox(width: 8),
              ref.watch(appRepositoryProvider).when(
                    data: (repo) => isMobile
                        ? IconButton.filled(
                            onPressed: () =>
                                _openPoolDialog(context, ref, repository: repo),
                            icon: const Icon(Icons.add_rounded),
                            tooltip: 'Tạo Phường',
                          )
                        : FilledButton.icon(
                            onPressed: () =>
                                _openPoolDialog(context, ref, repository: repo),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Tạo Phường'),
                          ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: poolsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(poolsProvider),
              ),
              data: (pools) {
                if (pools.isEmpty) {
                  return EmptyState(
                    icon: Icons.account_balance_outlined,
                    title: query.isEmpty
                        ? 'Chưa có Phường nào'
                        : 'Không tìm thấy Phường',
                    subtitle: query.isEmpty
                        ? 'Tạo Phường để tự động sinh ra các người Phường.'
                        : 'Hãy thử từ khóa khác.',
                  );
                }
                return ref
                    .watch(appRepositoryProvider)
                    .when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => ErrorView(
                        message: e.toString(),
                        onRetry: () => ref.invalidate(appRepositoryProvider),
                      ),
                      data: (repository) => ListView.separated(
                        controller: _scrollController,
                        itemCount: pools.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final pool = pools[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              14,
                                              8,
                                              14,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  cs.primary
                                                      .withValues(alpha: 0.08),
                                                  cs.tertiary
                                                      .withValues(alpha: 0.04),
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    pool.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                  ),
                                                ),
                                                IconButton(
                                                  tooltip: 'Xem người Phường',
                                                  onPressed: () {
                                                    ref
                                                        .read(
                                                          selectedPoolIdProvider
                                                              .notifier,
                                                        )
                                                        .state = pool.id;
                                                    ref
                                                        .read(
                                                          selectedTabProvider
                                                              .notifier,
                                                        )
                                                        .state = 2;
                                                  },
                                                  icon: Icon(
                                                    Icons.event_note_rounded,
                                                    color: cs.primary,
                                                  ),
                                                ),
                                                IconButton(
                                                  tooltip: 'Sửa',
                                                  onPressed: () =>
                                                      _openPoolDialog(
                                                    context,
                                                    ref,
                                                    repository: repository,
                                                    pool: pool,
                                                  ),
                                                  icon: Icon(
                                                    Icons.edit_rounded,
                                                    color: cs.primary,
                                                    size: 20,
                                                  ),
                                                ),
                                                IconButton(
                                                  tooltip: 'Xóa',
                                                  onPressed: () async {
                                                    final confirm =
                                                        await showConfirmDialog(
                                                      context,
                                                      'Xóa Phường',
                                                      'Bạn có chắc chắn muốn xóa Phường "${pool.name}" không? Toàn bộ dữ liệu của Phường này sẽ bị xóa.',
                                                      isDestructive: true,
                                                    );
                                                    if (!confirm ||
                                                        !context.mounted)
                                                      return;

                                                    try {
                                                      await repository
                                                          .deletePool(
                                                        pool.id,
                                                      );
                                                      if (ref.read(
                                                              selectedPoolIdProvider) ==
                                                          pool.id) {
                                                        ref
                                                            .read(
                                                              selectedPoolIdProvider
                                                                  .notifier,
                                                            )
                                                            .state = null;
                                                      }
                                                      refreshAll(ref);
                                                      if (context.mounted)
                                                        showSnackBar(
                                                          context,
                                                          'Đã xóa Phường',
                                                        );
                                                    } catch (e) {
                                                      if (context.mounted)
                                                        showSnackBar(
                                                          context,
                                                          e.toString(),
                                                          isError: true,
                                                        );
                                                    }
                                                  },
                                                  icon: Icon(
                                                    Icons.delete_rounded,
                                                    color: cs.error,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              12,
                                              16,
                                              16,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 6,
                                                  children: [
                                                    MiniChip(
                                                      icon: Icons
                                                          .payments_outlined,
                                                      label:
                                                          'Gốc ${formatMoney(pool.baseAmount)}',
                                                    ),
                                                    MiniChip(
                                                      icon: Icons
                                                          .repeat_rounded,
                                                      label:
                                                          '${pool.totalRounds} người',
                                                    ),
                                                    MiniChip(
                                                      icon: Icons
                                                          .calendar_today_rounded,
                                                      label:
                                                          'Ngày ${pool.meetingDay} âm lịch',
                                                      color: cs.primary,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Builder(
                                                  builder: (context) {
                                                    final dates =
                                                        const LunarScheduleService()
                                                            .generateMeetingDates(
                                                      startDate: pool.startDate,
                                                      totalRounds:
                                                          pool.totalRounds,
                                                      meetingDay:
                                                          pool.meetingDay,
                                                    );
                                                    final endDate =
                                                        dates.isNotEmpty
                                                            ? dates.last
                                                            : pool.startDate;
                                                    return Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .calendar_today_outlined,
                                                                size: 13,
                                                                color: cs
                                                                    .onSurfaceVariant),
                                                            const SizedBox(
                                                                width: 6),
                                                            Expanded(
                                                              child: Text(
                                                                'Âm: ${formatLunarDate(pool.startDate)} → ${formatLunarDate(endDate)}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: cs.primary),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .calendar_month_outlined,
                                                                size: 13,
                                                                color: cs
                                                                    .onSurfaceVariant),
                                                            const SizedBox(
                                                                width: 6),
                                                            Expanded(
                                                              child: Text(
                                                                'Dương: ~${formatSolarDate(pool.startDate)} → ~${formatSolarDate(endDate)}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: cs
                                                                        .onSurfaceVariant),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.payments_rounded,
                                                      size: 13,
                                                      color: cs.primary,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Tổng: ${formatMoney(pool.baseAmount * pool.totalRounds)}',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: cs.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 60),
                                  ],
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () async {
                                        final repo = repository;
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              FutureBuilder<List<dynamic>>(
                                            future: Future.wait([
                                              repo.getPoolMembers(pool.id),
                                              repo.getRoundsForPool(pool.id),
                                            ]),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              return PoolMembersDialog(
                                                pool: pool,
                                                members: snapshot.data![0],
                                                rounds: snapshot.data![1],
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 60,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                                color: cs.outlineVariant
                                                    .withValues(alpha: 0.3)),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.info_outline_rounded,
                                              color: cs.primary,
                                              size: 28,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Hội viên',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: cs.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openPoolDialog(
    BuildContext context,
    WidgetRef ref, {
    required AppRepository repository,
    Pool? pool,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => FutureBuilder<List<dynamic>>(
        future: Future.wait([
          repository.getUsers(),
          pool != null
              ? repository.getPoolMemberIds(pool.id)
              : Future.value(<int>[]),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('Lỗi'),
              content: Text(snapshot.error.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            );
          }

          final users = (snapshot.data?[0] as List<User>?) ?? const <User>[];
          final initialMemberIds =
              (snapshot.data?[1] as List<int>?) ?? const <int>[];
          return PoolDialog(
            pool: pool,
            users: users,
            initialMemberIds: initialMemberIds,
            onSave: (
              name,
              baseAmount,
              totalRounds,
              meetingDay,
              startDate,
              memberIds,
            ) async {
              await repository.savePool(
                id: pool?.id,
                name: name,
                baseAmount: baseAmount,
                totalRounds: totalRounds,
                meetingDay: meetingDay,
                startDate: startDate,
                memberIds: memberIds,
              );
              refreshAll(ref);
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    WidgetRef ref,
    int? filterDay,
  ) {
    final cs = Theme.of(context).colorScheme;
    final hasFilter = filterDay != null;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: hasFilter ? cs.primaryContainer : cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFilter ? cs.primary : cs.outlineVariant,
          width: hasFilter ? 1.5 : 1,
        ),
        boxShadow: hasFilter
            ? [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: InkWell(
        onTap: () async {
          final selected = await pickLunarDay(context, filterDay);
          if (selected != null) {
            ref.read(poolFilterDayProvider.notifier).state = selected;
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: hasFilter ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                hasFilter ? 'Ngày $filterDay' : 'Ngày họp',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: hasFilter ? FontWeight.bold : FontWeight.w500,
                  color: hasFilter ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
              ),
              if (hasFilter) ...[
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 20,
                  color: cs.primary.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: Icon(Icons.close_rounded, size: 18, color: cs.primary),
                  onPressed: () {
                    ref.read(poolFilterDayProvider.notifier).state = null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
