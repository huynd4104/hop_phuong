import 'package:hop_phuong/src/utils/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
import 'package:hop_phuong/src/models/statement_totals.dart';

class RoundsScreen extends ConsumerStatefulWidget {
  const RoundsScreen({super.key});

  @override
  ConsumerState<RoundsScreen> createState() => _RoundsScreenState();
}

class _RoundsScreenState extends ConsumerState<RoundsScreen> {
  final _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repositoryAsync = ref.watch(appRepositoryProvider);
    final poolsAsync = ref.watch(poolsProvider);
    final selectedPoolId = ref.watch(selectedPoolIdProvider);
    final membersAsync = ref.watch(selectedPoolMembersProvider);
    final roundsAsync = ref.watch(roundsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: repositoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(appRepositoryProvider),
        ),
        data: (repository) => poolsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(poolsProvider),
          ),
          data: (pools) {
            if (pools.isEmpty) {
              return const EmptyState(
                title: 'Không có Phường nào để xử lý',
                subtitle:
                    'Hãy tạo Phường trước. Ứng dụng sẽ tự động tạo tất cả các người Phường.',
              );
            }

            final pool = _resolveSelectedPool(pools, selectedPoolId);
            if (pool != null && selectedPoolId != pool.id) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ref.read(selectedPoolIdProvider.notifier).state = pool.id;
                }
              });
            }

            if (pool == null) {
              return const EmptyState(
                title: 'Chọn một Phường',
                subtitle:
                    'Chọn một Phường từ danh sách bên trên để xem và chỉnh sửa các người.',
              );
            }

            final isMobile = MediaQuery.sizeOf(context).width < 700;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm người theo số hoặc số tiền…',
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                        onChanged: (value) =>
                            ref.read(roundSearchProvider.notifier).state =
                                value,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        value: pool.id,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        items: pools
                            .map(
                              (item) => DropdownMenuItem<int>(
                                value: item.id,
                                child: Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(selectedPoolIdProvider.notifier).state =
                                value;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PoolHeaderCard(pool: pool),
                const SizedBox(height: 16),
                Expanded(
                  child: membersAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => ErrorView(
                      message: error.toString(),
                      onRetry: () =>
                          ref.invalidate(selectedPoolMembersProvider),
                    ),
                    data: (members) => roundsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => ErrorView(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(roundsProvider),
                      ),
                      data: (rounds) {
                        if (rounds.isEmpty) {
                          return const EmptyState(
                            title: 'Không tìm thấy người nào',
                            subtitle:
                                'Phường này có thể đang trống hoặc bộ lọc tìm kiếm không có kết quả.',
                          );
                        }

                        if (isMobile) {
                          return ListView.separated(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: rounds.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final round = rounds[index];
                              final winnerName = labelForUser(members, round.winnerId);
                              
                              return _RoundMobileCard(
                                round: round,
                                winnerName: winnerName,
                                pool: pool,
                                repository: repository,
                              );
                            },
                          );
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return Scrollbar(
                              controller: _horizontalScrollController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _horizontalScrollController,
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth,
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: DataTable(
                                      headingRowHeight: 48,
                                      dataRowMinHeight: 56,
                                      dataRowMaxHeight: 56,
                                      columnSpacing: 16,
                                      horizontalMargin: 12,
                                      columns: const [
                                        DataColumn(label: Text('Kỳ')),
                                        DataColumn(label: Text('Ngày')),
                                        DataColumn(label: Text('Người lấy')),
                                        DataColumn(label: Text('Tiền đấu')),
                                        DataColumn(label: Text('Tiền đóng')),
                                        DataColumn(label: Text('Tiền nhận')),
                                      ],
                                      rows: rounds
                                          .map((round) {
                                            final winnerName = labelForUser(
                                              members,
                                              round.winnerId,
                                            );
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Text('${round.roundNumber}'),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 110,
                                                    child: Text(
                                                      formatLunarDate(
                                                        round.date,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    winnerName,
                                                    style: TextStyle(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  onTap: () => openRoundDialog(
                                                    context,
                                                    ref,
                                                    repository: repository,
                                                    pool: pool,
                                                    round: round,
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    formatMoney(
                                                      round.bidAmount,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Consumer(
                                                    builder: (context, ref, _) {
                                                      final fullyPaidAsync = ref
                                                          .watch(
                                                            fullyPaidContributionRoundsProvider,
                                                          );
                                                      final isPaid =
                                                          fullyPaidAsync.value
                                                              ?.contains(
                                                                round.id,
                                                              ) ??
                                                          false;

                                                      return Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            formatMoney(
                                                              round
                                                                  .contributionAmount,
                                                            ),
                                                            style: TextStyle(
                                                              color: isPaid
                                                                  ? Colors.green
                                                                  : Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .secondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          if (isPaid) ...[
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            const Icon(
                                                              Icons
                                                                  .check_circle_rounded,
                                                              color:
                                                                  Colors.green,
                                                              size: 14,
                                                            ),
                                                          ],
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  onTap: () =>
                                                      openPaymentsSheet(
                                                        context,
                                                        ref,
                                                        repository: repository,
                                                        pool: pool,
                                                        round: round,
                                                        showOnlyWinner: false,
                                                      ),
                                                ),
                                                DataCell(
                                                  Consumer(
                                                    builder: (context, ref, _) {
                                                      final winnerPaidAsync =
                                                          ref.watch(
                                                            winnerPaidRoundsProvider,
                                                          );
                                                      final isPaid =
                                                          winnerPaidAsync.value
                                                              ?.contains(
                                                                round.id,
                                                              ) ??
                                                          false;

                                                      return Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            formatMoney(
                                                              round
                                                                  .netReceiveAmount,
                                                            ),
                                                            style: TextStyle(
                                                              color: isPaid
                                                                  ? Colors.green
                                                                  : Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .tertiary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          if (isPaid) ...[
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            const Icon(
                                                              Icons
                                                                  .check_circle_rounded,
                                                              color:
                                                                  Colors.green,
                                                              size: 14,
                                                            ),
                                                          ],
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  onTap: () =>
                                                      openPaymentsSheet(
                                                        context,
                                                        ref,
                                                        repository: repository,
                                                        pool: pool,
                                                        round: round,
                                                        showOnlyWinner: true,
                                                      ),
                                                ),
                                              ],
                                            );
                                          })
                                          .toList(growable: false),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Pool? _resolveSelectedPool(List<Pool> pools, int? selectedPoolId) {
    if (selectedPoolId != null) {
      for (final pool in pools) {
        if (pool.id == selectedPoolId) {
          return pool;
        }
      }
    }
    return pools.isEmpty ? null : pools.first;
  }
}

class _RoundMobileCard extends ConsumerWidget {
  final Round round;
  final String winnerName;
  final Pool pool;
  final AppRepository repository;

  const _RoundMobileCard({
    required this.round,
    required this.winnerName,
    required this.pool,
    required this.repository,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header: Round Info
          InkWell(
            onTap: () => openRoundDialog(
              context,
              ref,
              repository: repository,
              pool: pool,
              round: round,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${round.roundNumber}',
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          winnerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Âm lịch: ${formatLunarDate(round.date)}',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: cs.outline),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
          // Data Section: Amounts
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _AmountItem(
                  label: 'Tiền đấu',
                  amount: round.bidAmount,
                  color: cs.primary,
                ),
                _AmountItem(
                  label: 'Tiền đóng',
                  amount: round.contributionAmount,
                  color: cs.secondary,
                  onTap: () => openPaymentsSheet(
                    context,
                    ref,
                    repository: repository,
                    pool: pool,
                    round: round,
                    showOnlyWinner: false,
                  ),
                  isPaidProvider: fullyPaidContributionRoundsProvider,
                  roundId: round.id,
                ),
                _AmountItem(
                  label: 'Tiền nhận',
                  amount: round.netReceiveAmount,
                  color: cs.tertiary,
                  onTap: () => openPaymentsSheet(
                    context,
                    ref,
                    repository: repository,
                    pool: pool,
                    round: round,
                    showOnlyWinner: true,
                  ),
                  isPaidProvider: winnerPaidRoundsProvider,
                  roundId: round.id,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountItem extends ConsumerWidget {
  final String label;
  final int amount;
  final Color color;
  final VoidCallback? onTap;
  final ProviderListenable<AsyncValue<Set<int>>>? isPaidProvider;
  final int? roundId;

  const _AmountItem({
    required this.label,
    required this.amount,
    required this.color,
    this.onTap,
    this.isPaidProvider,
    this.roundId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isPaid = isPaidProvider != null && roundId != null
        ? ref.watch(isPaidProvider!).value?.contains(roundId!) ?? false
        : false;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    formatMoney(amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isPaid ? Colors.green : color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isPaid) ...[
                  const SizedBox(width: 2),
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 12),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
