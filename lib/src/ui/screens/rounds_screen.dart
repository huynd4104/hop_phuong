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
                          prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: (value) => ref.read(roundSearchProvider.notifier).state = value,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        initialValue: pool.id,
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
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return Scrollbar(
                              controller: _horizontalScrollController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _horizontalScrollController,
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: DataTable(
                                      headingRowHeight: 48,
                                      dataRowMinHeight: 56,
                                      dataRowMaxHeight: 56,
                                      columnSpacing: 16,
                                      horizontalMargin: 12,
                                      columns: const [
                                        DataColumn(label: Text('Tháng')),
                                        DataColumn(label: Text('Ngày')),
                                        DataColumn(label: Text('Người lấy')),
                                        DataColumn(label: Text('Tiền đấu')),
                                        DataColumn(label: Text('Đóng vào')),
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
                                                    width: 90,
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: 'Â: ${formatLunarDate(round.date)}\n',
                                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                          ),
                                                          TextSpan(
                                                            text: 'D: ${formatSolarDate(round.date)}',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    winnerName,
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.primary,
                                                      fontWeight: FontWeight.bold,
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
                                                  Text(formatMoney(round.bidAmount)),
                                                ),
                                                DataCell(
                                                  Consumer(
                                                    builder: (context, ref, _) {
                                                      final fullyPaidAsync = ref.watch(fullyPaidContributionRoundsProvider);
                                                      final isPaid = fullyPaidAsync.value?.contains(round.id) ?? false;
                                                      
                                                      return Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            formatMoney(round.contributionAmount),
                                                            style: TextStyle(
                                                              color: isPaid ? Colors.green : Theme.of(context).colorScheme.secondary,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          if (isPaid) ...[
                                                            const SizedBox(width: 4),
                                                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                                                          ],
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  onTap: () => openPaymentsSheet(
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
                                                      final winnerPaidAsync = ref.watch(winnerPaidRoundsProvider);
                                                      final isPaid = winnerPaidAsync.value?.contains(round.id) ?? false;
                                                      
                                                      return Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            formatMoney(round.netReceiveAmount),
                                                            style: TextStyle(
                                                              color: isPaid ? Colors.green : Theme.of(context).colorScheme.tertiary,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          if (isPaid) ...[
                                                            const SizedBox(width: 4),
                                                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                                                          ],
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  onTap: () => openPaymentsSheet(
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
