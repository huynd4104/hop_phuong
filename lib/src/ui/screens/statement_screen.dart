import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hop_phuong/src/models/statement_models.dart';
import 'package:hop_phuong/src/providers/app_providers.dart';
import 'package:hop_phuong/src/ui/widgets/empty_state.dart';
import 'package:hop_phuong/src/ui/widgets/error_view.dart';
import 'package:hop_phuong/src/utils/formatters.dart';
import 'package:hop_phuong/src/utils/ui_helpers.dart';

class StatementScreen extends ConsumerStatefulWidget {
  const StatementScreen({super.key});

  @override
  ConsumerState<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends ConsumerState<StatementScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedYear = ref.watch(statementSelectedYearProvider);
    final selectedMonth = ref.watch(statementSelectedMonthProvider);
    final selectedRoundIds = ref.watch(statementSelectedRoundIdsProvider);
    final query = ref.watch(statementSearchProvider);
    final statementAsync = ref.watch(statementProvider);

    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Modern Header & Filter Section ---
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: cs.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm tên, số điện thoại...',
                          prefixIcon: Icon(Icons.search_rounded, color: cs.primary, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 14),
                        ),
                        onChanged: (value) => ref.read(statementSearchProvider.notifier).state = value,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _FilterStatusBadge(
                    year: selectedYear,
                    month: selectedMonth,
                    onTap: () => _openStatementSelector(context),
                  ),
                ],
              ),
              if (selectedRoundIds.isNotEmpty) ...[
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.layers_outlined, size: 14, color: cs.onPrimaryContainer),
                            const SizedBox(width: 6),
                            Text(
                              'Đã chọn ${selectedRoundIds.length} kỳ phường',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Nút xóa nhanh tất cả filter kỳ
                      IconButton(
                        onPressed: () => ref.read(statementSelectedRoundIdsProvider.notifier).state = {},
                        icon: const Icon(Icons.close_rounded, size: 16),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.surfaceContainerHighest,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(28, 28),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        // --- Statement List Section ---
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: statementAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(statementProvider),
              ),
              data: (rows) {
                if (selectedRoundIds.isEmpty) {
                  return const EmptyState(
                    title: 'Chưa chọn kỳ phường',
                    subtitle:
                        'Chọn năm, tháng rồi chạm vào các kỳ phường cần thống kê, sau đó nhấn OK.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: rows.isEmpty
                          ? EmptyState(
                              title: query.isEmpty
                                  ? 'Không có dữ liệu bảng kê'
                                  : 'Không tìm thấy người dùng',
                              subtitle:
                                  'Hãy đổi kỳ phường đã chọn hoặc xóa bộ lọc tìm kiếm.',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: rows.length,
                              separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final row = rows[index];
                                final initials = row.userName.isEmpty
                                    ? '?'
                                    : row.userName
                                          .trim()
                                          .split(' ')
                                          .map(
                                            (word) =>
                                                word.isNotEmpty ? word[0] : '',
                                          )
                                          .take(2)
                                          .join()
                                          .toUpperCase();
                                final hue = row.userName.hashCode % 6;
                                final avatarColors = [
                                  [
                                    const Color(0xFF1A73E8),
                                    const Color(0xFF4FC3F7),
                                  ],
                                  [
                                    const Color(0xFF0D7A6F),
                                    const Color(0xFF4DB6AC),
                                  ],
                                  [
                                    const Color(0xFFE53935),
                                    const Color(0xFFFF8A80),
                                  ],
                                  [
                                    const Color(0xFF7B1FA2),
                                    const Color(0xFFCE93D8),
                                  ],
                                  [
                                    const Color(0xFFF57C00),
                                    const Color(0xFFFFCC80),
                                  ],
                                  [
                                    const Color(0xFF2E7D32),
                                    const Color(0xFFA5D6A7),
                                  ],
                                ];
                                final cs = Theme.of(context).colorScheme;

                                return Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () =>
                                        _openStatementDetail(context, row),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: avatarColors[hue],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                initials,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  row.userName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.phone_rounded,
                                                      size: 13,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      row.phone,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            cs.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                formatMoney(row.netBalance),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16,
                                                  color: row.netBalance >= 0
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                              if (row.isAllPaid)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.check_rounded, size: 10, color: Colors.green),
                                                        SizedBox(width: 2),
                                                        Text(
                                                          'Xong',
                                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              else if (row.remainingBalance != 0)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    row.remainingBalance > 0 
                                                        ? 'Chưa giao: ${formatMoney(row.remainingBalance)}' 
                                                        : 'Nợ: ${formatMoney(row.remainingBalance.abs())}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: row.remainingBalance > 0 ? Colors.blue : Colors.orange,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
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
        ),
      ],
    );
  }

  Future<int?> _pickYear(BuildContext context, int selectedYear) async {
    return showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Chọn năm âm lịch'),
          content: SizedBox(
            width: 320,
            height: 360,
            child: YearPicker(
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              selectedDate: DateTime(selectedYear),
              onChanged: (value) => Navigator.of(dialogContext).pop(value.year),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openStatementSelector(BuildContext context) async {
    final initialYear = ref.read(statementSelectedYearProvider);
    final initialMonth = ref.read(statementSelectedMonthProvider);
    final initialSelectedIds = ref.read(statementSelectedRoundIdsProvider).toSet();

    var pickerYear = initialYear;
    var pickerMonth = initialMonth;
    var selectedIds = <int>{...initialSelectedIds};
    var options = <StatementRoundOption>[];
    var isLoading = false;

    Future<void> loadOptions(StateSetter setState) async {
      if (pickerMonth == null) {
        setState(() {
          options = <StatementRoundOption>[];
          selectedIds = <int>{};
          isLoading = false;
        });
        return;
      }

      setState(() => isLoading = true);

      final repository = await ref.read(appRepositoryProvider.future);
      final loadedOptions = await repository.getStatementRoundOptions(
        month: pickerMonth!,
        year: pickerYear,
      );
      final availableIds = loadedOptions.map((item) => item.roundId).toSet();

      setState(() {
        options = loadedOptions;
        selectedIds = selectedIds.intersection(availableIds);
        isLoading = false;
      });
    }

    if (pickerMonth != null) {
      final repository = await ref.read(appRepositoryProvider.future);
      options = await repository.getStatementRoundOptions(
        month: pickerMonth!,
        year: pickerYear,
      );
    }

    if (!context.mounted) return;

    final size = MediaQuery.sizeOf(context);
    final useDialog = size.width >= 720;
    final contentMaxWidth = size.width >= 1200 ? 920.0 : 720.0;

    final isMobile = size.width < 600;

    Widget buildSelectorContent(BuildContext panelContext, StateSetter setState) {
      final cs = Theme.of(panelContext).colorScheme;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header: Year Selection ---
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final pickedYear = await _pickYear(panelContext, pickerYear);
                    if (pickedYear == null) return;
                    setState(() {
                      pickerYear = pickedYear;
                      pickerMonth = null;
                      options = [];
                      selectedIds = {};
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.primary.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: cs.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Năm âm lịch: $pickerYear',
                          style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary, fontSize: 15),
                        ),
                        const Spacer(),
                        Icon(Icons.unfold_more_rounded, size: 20, color: cs.primary),
                      ],
                    ),
                  ),
                ),
              ),
              if (selectedIds.isNotEmpty) ...[
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: () => setState(() => selectedIds = {}),
                  icon: const Icon(Icons.layers_clear_rounded, size: 20),
                  tooltip: 'Bỏ chọn tất cả',
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // --- Month Grid ---
          Text(
            'Chọn tháng',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: size.width > 900 ? 6 : (size.width > 400 ? 4 : 3),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: isMobile ? 1.8 : 2.2,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = pickerMonth == month;
              return InkWell(
                onTap: () {
                  setState(() {
                    pickerMonth = month;
                    selectedIds = {};
                  });
                  loadOptions(setState);
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary : cs.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'T$month',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? cs.onPrimary : cs.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // --- Options List ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kỳ phường trong tháng',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant),
              ),
              if (options.isNotEmpty)
                Text(
                  '${options.length} kỳ',
                  style: TextStyle(fontSize: 12, color: cs.primary, fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : options.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy_rounded, size: 48, color: cs.outlineVariant),
                            const SizedBox(height: 12),
                            Text(
                              pickerMonth == null ? 'Vui lòng chọn tháng' : 'Không có kỳ phường nào',
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: options.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final opt = options[index];
                          final isSel = selectedIds.contains(opt.roundId);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSel) {
                                  selectedIds.remove(opt.roundId);
                                } else {
                                  selectedIds.add(opt.roundId);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSel ? cs.primaryContainer.withValues(alpha: 0.5) : cs.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSel ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
                                  width: isSel ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isSel ? cs.primary : cs.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${opt.roundNumber}',
                                      style: TextStyle(
                                        color: isSel ? cs.onPrimary : cs.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Âm: ${formatLunarDate(opt.date)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 17,
                                            color: cs.primary,
                                          ),
                                        ),
                                        Text(
                                          opt.poolName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: cs.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    value: isSel,
                                    onChanged: (v) {
                                      setState(() {
                                        if (v == true) {
                                          selectedIds.add(opt.roundId);
                                        } else {
                                          selectedIds.remove(opt.roundId);
                                        }
                                      });
                                    },
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 16),

          // --- Actions ---
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(panelContext),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Hủy bỏ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: selectedIds.isEmpty
                      ? null
                      : () {
                          ref.read(statementSelectedYearProvider.notifier).state = pickerYear;
                          if (pickerMonth != null) {
                            ref.read(statementSelectedMonthProvider.notifier).state = pickerMonth;
                          }
                          ref.read(statementSelectedRoundIdsProvider.notifier).state = selectedIds.toSet();
                          Navigator.pop(panelContext);
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Áp dụng bộ lọc'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (useDialog) {
      await showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            width: contentMaxWidth,
            height: size.height * 0.85,
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(builder: buildSelectorContent),
          ),
        ),
      );
    } else {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
        final cs = Theme.of(context).colorScheme;
        return Container(
          height: size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(child: StatefulBuilder(builder: buildSelectorContent)),
            ],
          ),
        );
      },
      );
    }
  }

  void _openStatementDetail(BuildContext context, UserMonthlyStatement initialRow) {
    final userId = initialRow.userId;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, _) {
                final statementAsync = ref.watch(statementProvider);
                final statements = statementAsync.value;
                final row = statements?.firstWhere(
                  (s) => s.userId == userId,
                  orElse: () => initialRow,
                ) ?? initialRow;

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.userName,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
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
                                      row.netBalance >= 0 ? 'Tổng giao' : 'Tổng đóng',
                                      style: TextStyle(
                                        color: row.netBalance >= 0 ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 24),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatMoney(row.remainingBalance.abs()),
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: row.remainingBalance >= 0 ? Colors.blue : Colors.orange,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      row.remainingBalance >= 0 ? 'Chưa giao' : 'Tổng nợ',
                                      style: TextStyle(
                                        color: row.remainingBalance >= 0 ? Colors.blue : Colors.orange,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (statementAsync.isLoading)
                        const LinearProgressIndicator(minHeight: 2),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: row.breakdowns.length,
                          itemBuilder: (context, index) {
                            final breakdown = row.breakdowns[index];
                            final isReceive = breakdown.netBalance >= 0;

                            return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => _openSettlementDialog(context, userId, breakdown),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    breakdown.poolName,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Tháng ${breakdown.roundNumbers.join(', ')}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                        ),
                                                      ),
                                                      if (breakdown.remainingBalance != 0) ...[
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          breakdown.remainingBalance > 0 ? 'Chưa giao: ${formatMoney(breakdown.remainingBalance)}' : 'Nợ: ${formatMoney(breakdown.remainingBalance.abs())}',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: breakdown.remainingBalance > 0 ? Colors.blue : Colors.orange,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (breakdown.isPaid)
                                              const Icon(Icons.check_circle_rounded, color: Colors.green)
                                            else
                                              const Icon(Icons.pending_actions_rounded, color: Colors.orange),
                                          ],
                                        ),
                                        const Divider(height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  isReceive ? 'Giao' : 'Đóng',
                                                  style: TextStyle(
                                                    color: isReceive
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  formatMoney(breakdown.netBalance.abs()),
                                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Thực tế: ${formatMoney(breakdown.actualAmount.abs())}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15,
                                                    color: isReceive
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                ),
                                                Icon(Icons.chevron_right_rounded, size: 16, color: Theme.of(context).colorScheme.outlineVariant),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _openSettlementDialog(
    BuildContext context,
    int userId,
    PoolStatementBreakdown breakdown,
  ) async {
    final cs = Theme.of(context).colorScheme;
    final isReceive = breakdown.netBalance >= 0;
    
    final expectedAmount = breakdown.netBalance.abs();
    final currentActual = breakdown.actualAmount.abs();
    final initialRemaining = breakdown.remainingBalance;

    final amountController = TextEditingController();
    final noteController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isReceive ? 'Thanh toán Giao' : 'Thanh toán Đóng'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            final rawInput = parseMoney(amountController.text);
            final newAmount = isReceive ? rawInput : -rawInput;
            final newRemaining = initialRemaining - newAmount;
            
            final maxPossible = initialRemaining.abs();
            final isOverLimit = rawInput > maxPossible;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    breakdown.poolName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dự kiến: ${formatMoney(expectedAmount)}',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                      ),
                      Text(
                        'Đã trả: ${formatMoney(currentActual)}',
                        style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (breakdown.history.isNotEmpty) ...[
                    const Text(
                      'Lịch sử thanh toán:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    ...breakdown.history.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatMoney(e.amount.abs()),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              Text(
                                formatLunarDate(e.date),
                                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                              ),
                            ],
                          ),
                          if (e.note != null && e.note!.isNotEmpty)
                            Expanded(
                              child: Text(
                                e.note!,
                                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11, fontStyle: FontStyle.italic),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    )),
                    const Divider(height: 24),
                  ],
                  TextField(
                    controller: amountController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: isReceive ? 'Số tiền GIAO THÊM' : 'Số tiền ĐÓNG THÊM',
                      prefixText: '₫ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      errorText: isOverLimit ? 'Vượt quá số tiền còn lại (${formatMoney(maxPossible)})' : null,
                      helperText: 'Nhập số tiền thực tế giao dịch lần này',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyInputFormatter()],
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: newRemaining >= 0 ? Colors.blue.withValues(alpha: 0.05) : Colors.orange.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: newRemaining >= 0 ? Colors.blue.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          newRemaining >= 0 ? 'Chưa giao sau khi lưu:' : 'Nợ sau khi lưu:',
                          style: TextStyle(fontWeight: FontWeight.w600, color: newRemaining >= 0 ? Colors.blue : Colors.orange),
                        ),
                        Text(
                          formatMoney(newRemaining.abs()),
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: newRemaining >= 0 ? Colors.blue : Colors.orange),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: 'Ghi chú cho lần này',
                      hintText: 'Ví dụ: Trả qua bank, Nợ đến tháng sau...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final rawInput = parseMoney(amountController.text);
              final maxPossible = initialRemaining.abs();
              if (rawInput == 0 || rawInput > maxPossible) return;
              
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Xác nhận & Lưu'),
          ),
        ],
      ),
    );

    if (result == true) {
      final rawAmount = parseMoney(amountController.text);
      final amountToAdd = isReceive ? rawAmount : -rawAmount;
      final note = noteController.text.trim();
      
      final newRemaining = initialRemaining - amountToAdd;
      final isPaid = newRemaining == 0;

      final repository = await ref.read(appRepositoryProvider.future);
      
      for (int i = 0; i < breakdown.roundIds.length; i++) {
        final roundId = breakdown.roundIds[i];
        await repository.setPaymentStatus(
          userId: userId,
          roundId: roundId,
          isPaid: isPaid,
          amountToAdd: (i == 0 && rawAmount != 0) ? amountToAdd : null,
          note: (i == 0 && note.isNotEmpty) ? note : null,
        );
      }
      
      refreshAll(ref);
    }
  }
}

class _FilterStatusBadge extends StatelessWidget {
  final int year;
  final int? month;
  final VoidCallback onTap;

  const _FilterStatusBadge({
    required this.year,
    required this.month,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 16, color: cs.onPrimary),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Năm $year',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  month == null ? 'Chọn tháng' : 'Tháng $month',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
