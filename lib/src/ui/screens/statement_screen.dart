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
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) =>
                      ref.read(statementSearchProvider.notifier).state = value,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 180,
                child: OutlinedButton.icon(
                  onPressed: () => _openStatementSelector(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.event_note_outlined, size: 18),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Năm $selectedYear',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        selectedMonth == null
                            ? 'Chọn tháng'
                            : 'Tháng $selectedMonth',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                selectedRoundIds.isEmpty
                    ? 'Chưa chọn kỳ nào'
                    : 'Đã chọn ${selectedRoundIds.length} kỳ',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
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
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () =>
                                        _openStatementDetail(context, row),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          IgnorePointer(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Checkbox(
                                                value: row.isAllPaid,
                                                onChanged: (_) {},
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
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
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.phone_outlined,
                                                      size: 13,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      row.phone,
                                                      style: TextStyle(
                                                        fontSize: 13,
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
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: row.netBalance >= 0
                                                      ? Colors.green
                                                      : Colors.red,
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
        ],
      ),
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
    final initialSelectedIds = ref
        .read(statementSelectedRoundIdsProvider)
        .toSet();

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

      setState(() {
        isLoading = true;
      });

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
        month: pickerMonth,
        year: pickerYear,
      );
      final availableIds = options.map((item) => item.roundId).toSet();
      selectedIds = selectedIds.intersection(availableIds);
    }

    if (!context.mounted) return;

    final size = MediaQuery.sizeOf(context);
    final isLandscape = size.width > size.height;
    final useDialog = size.width >= 720;
    final monthColumnCount = size.width >= 900
      ? 6
      : size.width >= 560
        ? 4
        : 3;
    final optionGridLayout = size.width >= 840;
    final contentMaxWidth = size.width >= 1200 ? 920.0 : 720.0;

    Widget buildSelectorContent(BuildContext panelContext, StateSetter setState) {
      final cs = Theme.of(panelContext).colorScheme;

      Widget buildMonthTile(int month) {
        final isSelected = pickerMonth == month;
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              pickerMonth = month;
              selectedIds = <int>{};
            });
            loadOptions(setState);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected ? cs.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? cs.primary : cs.outlineVariant,
              ),
            ),
            child: Center(
              child: Text(
                'Tháng $month',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? cs.onPrimary : cs.onSurface,
                ),
              ),
            ),
          ),
        );
      }

      Widget buildOptionCard(StatementRoundOption option) {
        final isSelected = selectedIds.contains(option.roundId);
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedIds.remove(option.roundId);
              } else {
                selectedIds.add(option.roundId);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? cs.primaryContainer : cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? cs.primary : cs.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: optionGridLayout
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? cs.primary
                                  : cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Kỳ ${option.roundNumber}',
                              style: TextStyle(
                                color: isSelected ? cs.onPrimary : cs.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 18,
                            color: isSelected ? cs.primary : cs.outline,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        option.poolName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bắt đầu: ${formatSolarDate(option.poolStartDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Âm: ${formatLunarDate(option.date)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.primary
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Kỳ ${option.roundNumber}',
                          style: TextStyle(
                            color: isSelected ? cs.onPrimary : cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.poolName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bắt đầu: ${formatSolarDate(option.poolStartDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Âm: ${formatLunarDate(option.date)}',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      }

      Widget buildOptionsArea() {
        if (pickerMonth == null) {
          return Center(
            child: Text(
              'Chọn một tháng để xem toàn bộ kỳ phường trong tháng đó.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          );
        }

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (options.isEmpty) {
          return Center(
            child: Text(
              'Tháng này chưa có kỳ phường nào.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          );
        }

        if (optionGridLayout) {
          return GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisExtent: 118,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) => buildOptionCard(options[index]),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: options.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) => buildOptionCard(options[index]),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    final pickedYear = await _pickYear(
                      panelContext,
                      pickerYear,
                    );
                    if (pickedYear == null) return;
                    setState(() {
                      pickerYear = pickedYear;
                      pickerMonth = null;
                      options = <StatementRoundOption>[];
                      selectedIds = <int>{};
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Năm $pickerYear',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: cs.onPrimaryContainer,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: selectedIds.isEmpty
                    ? null
                    : () {
                        setState(() {
                          selectedIds = <int>{};
                        });
                      },
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Bỏ chọn'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: monthColumnCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 8,
            childAspectRatio: monthColumnCount >= 6
                ? 3.35
                : monthColumnCount == 4
                    ? 3.05
                    : 2.75,
            children: [
              for (var month = 1; month <= 12; month++) buildMonthTile(month),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: buildOptionsArea()),
          const SizedBox(height: 16),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 12,
            overflowSpacing: 8,
            children: [
              TextButton(
                onPressed: () => Navigator.of(panelContext).pop(),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: selectedIds.isEmpty
                    ? null
                    : () {
                        ref
                            .read(statementSelectedYearProvider.notifier)
                            .state = pickerYear;
                        if (pickerMonth != null) {
                          ref
                              .read(statementSelectedMonthProvider.notifier)
                              .state = pickerMonth;
                        }
                        ref
                            .read(statementSelectedRoundIdsProvider.notifier)
                            .state = selectedIds.toSet();
                        Navigator.of(panelContext).pop();
                      },
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      );
    }

    if (useDialog) {
      final dialogHeight = isLandscape ? size.height * 0.72 : size.height * 0.9;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 12 : 20,
              vertical: isLandscape ? 12 : 24,
            ),
            child: SizedBox(
              width: contentMaxWidth,
              height: dialogHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLandscape ? 16 : 20,
                  vertical: isLandscape ? 12 : 20,
                ),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: dialogHeight -
                              (isLandscape ? 24 : 40),
                        ),
                        child: IntrinsicHeight(
                          child: buildSelectorContent(context, setState),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.98,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                final cs = Theme.of(context).colorScheme;
                return Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        4,
                        20,
                        MediaQuery.viewInsetsOf(context).bottom + 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: buildSelectorContent(context, setState),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _openStatementDetail(BuildContext context, UserMonthlyStatement row) {
    final localPaidState = {
      for (final breakdown in row.breakdowns)
        breakdown.poolId: breakdown.isPaid,
    };
    final selectedYear = ref.read(statementSelectedYearProvider);
    final selectedMonth = ref.read(statementSelectedMonthProvider);

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
            return StatefulBuilder(
              builder: (context, setState) {
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
                                  'Năm: $selectedYear',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tháng: ${selectedMonth ?? '-'}',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatMoney(row.netBalance.abs()),
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: row.netBalance >= 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  row.netBalance >= 0
                                      ? 'Tổng lĩnh'
                                      : 'Tổng đóng',
                                  style: TextStyle(
                                    color: row.netBalance >= 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                          itemCount: row.breakdowns.length,
                          itemBuilder: (context, index) {
                            final breakdown = row.breakdowns[index];
                            final roundText = breakdown.roundNumbers.isNotEmpty
                                ? ' - Kỳ ${breakdown.roundNumbers.join(', ')}'
                                : '';
                            final isReceive = breakdown.netBalance >= 0;
                            final isPaid =
                                localPaidState[breakdown.poolId] ?? false;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: Checkbox(
                                  value: isPaid,
                                  onChanged: (value) async {
                                    if (value == null) return;

                                    final confirm = await showConfirmDialog(
                                      context,
                                      'Xác nhận cập nhật',
                                      'Bạn có chắc chắn muốn cập nhật trạng thái thanh toán?',
                                    );
                                    if (!confirm) return;

                                    setState(
                                      () => localPaidState[breakdown.poolId] =
                                          value,
                                    );
                                    final repository = await ref.read(
                                      appRepositoryProvider.future,
                                    );
                                    for (final roundId in breakdown.roundIds) {
                                      await repository.setPaymentStatus(
                                        userId: row.userId,
                                        roundId: roundId,
                                        isPaid: value,
                                      );
                                    }
                                    ref.invalidate(statementProvider);
                                  },
                                ),
                                title: Text(
                                  '${breakdown.poolName}$roundText',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isReceive ? 'Lĩnh' : 'Đóng',
                                        style: TextStyle(
                                          color: isReceive
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (breakdown.roundDates.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    'Âm: ${formatLunarDate(breakdown.roundDates.first)}\n',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    'Dương: ~${formatSolarDate(breakdown.roundDates.first)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
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
                                    color: isReceive
                                        ? Colors.green
                                        : Colors.red,
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
}
