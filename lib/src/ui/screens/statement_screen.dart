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


class StatementScreen extends ConsumerStatefulWidget {
  const StatementScreen({super.key});

  @override
  ConsumerState<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends ConsumerState<StatementScreen> {


  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(statementMonthProvider);
    final query = ref.watch(statementSearchProvider);
    final statementAsync = ref.watch(statementProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm tên hoặc số điện thoại…',
                    prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) => ref.read(statementSearchProvider.notifier).state = value,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await pickMonthYear(context, filter);
                    if (selected != null) {
                      ref.read(statementMonthProvider.notifier).state = selected;
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Âm: ${filter.month.toString().padLeft(2, '0')}/${filter.year}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('Dương: ~${LunarCalendar.lunarToSolar(1, filter.month, filter.year).month.toString().padLeft(2, '0')}/${LunarCalendar.lunarToSolar(1, filter.month, filter.year).year}', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: statementAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorView(message: error.toString(), onRetry: () => ref.invalidate(statementProvider)),
              data: (rows) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    Expanded(
                      child: rows.isEmpty
                          ? EmptyState(
                              title: query.isEmpty ? 'Không có dữ liệu bảng kê' : 'Không tìm thấy người dùng',
                              subtitle: 'Hãy đổi kỳ hoặc xóa bộ lọc tìm kiếm.',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: rows.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final row = rows[index];
                                final initials = row.userName.isEmpty ? '?' : row.userName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
                                final hue = (row.userName.hashCode % 6);
                                final avatarColors = [
                                  [const Color(0xFF1A73E8), const Color(0xFF4FC3F7)],
                                  [const Color(0xFF0D7A6F), const Color(0xFF4DB6AC)],
                                  [const Color(0xFFE53935), const Color(0xFFFF8A80)],
                                  [const Color(0xFF7B1FA2), const Color(0xFFCE93D8)],
                                  [const Color(0xFFF57C00), const Color(0xFFFFCC80)],
                                  [const Color(0xFF2E7D32), const Color(0xFFA5D6A7)],
                                ];
                                final cs = Theme.of(context).colorScheme;

                                return Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () => _openStatementDetail(context, row),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              IgnorePointer(
                                                child: SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: Checkbox(
                                                    value: row.isAllPaid,
                                                    onChanged: (_) {},
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: avatarColors[hue],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(row.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                                    Text(row.phone, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(formatMoney(row.netBalance),
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 16,
                                                        color: row.netBalance >= 0 ? Colors.green : Colors.red,
                                                      )),
                                                ],
                                              ),
                                            ],
                                          ),
                                          // Removed row totals

                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // _statementTotals removed

  void _openStatementDetail(BuildContext context, UserMonthlyStatement row) {
    final localPaidState = { for (final b in row.breakdowns) b.poolId: b.isPaid };
    final filter = ref.read(statementMonthProvider);
    final solarDate = LunarCalendar.lunarToSolar(1, filter.month, filter.year);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              primary: false,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lịch âm: ${filter.month}/${filter.year}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Dương lịch: ~${solarDate.month}/${solarDate.year}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatMoney(row.netBalance.abs()),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: row.netBalance >= 0 ? Colors.green : Colors.red,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            row.netBalance >= 0 ? 'Tổng lĩnh' : 'Tổng đóng',
                            style: TextStyle(
                              color: row.netBalance >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...row.breakdowns.map(
                    (breakdown) {
                      final roundText = breakdown.roundNumbers.isNotEmpty ? ' - Người ${breakdown.roundNumbers.join(", ")}' : '';
                      final isReceive = breakdown.netBalance >= 0;
                      final isPaid = localPaidState[breakdown.poolId] ?? false;

                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: isPaid,
                            onChanged: (val) async {
                              if (val == null) return;
                              
                              final confirm = await showConfirmDialog(
                                context,
                                'Xác nhận cập nhật',
                                'Bạn có chắc chắn muốn cập nhật trạng thái thanh toán?',
                              );
                              if (!confirm) return;

                              setState(() => localPaidState[breakdown.poolId] = val);
                              final repo = await ref.read(appRepositoryProvider.future);
                              for (final roundId in breakdown.roundIds) {
                                await repo.setPaymentStatus(
                                  userId: row.userId,
                                  roundId: roundId,
                                  isPaid: val,
                                );
                              }
                              ref.invalidate(statementProvider);
                            },
                          ),
                          title: Text('${breakdown.poolName}$roundText', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isReceive ? 'Lĩnh' : 'Đóng',
                                  style: TextStyle(
                                    color: isReceive ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (breakdown.roundDates.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(text: 'Âm: ${formatLunarDate(breakdown.roundDates.first)}\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        TextSpan(text: 'Dương: ~${formatSolarDate(breakdown.roundDates.first)}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          trailing: Text(
                            formatMoney(breakdown.netBalance.abs()), 
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: isReceive ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // _buildMiniStat removed
}

