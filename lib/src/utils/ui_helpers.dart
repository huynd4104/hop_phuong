import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hop_phuong/src/data/app_repository.dart';
import 'package:hop_phuong/src/models/pool_entity.dart';
import 'package:hop_phuong/src/models/round_entity.dart';
import 'package:hop_phuong/src/models/user_entity.dart';
import 'package:hop_phuong/src/models/payment_status_entity.dart';
import 'package:hop_phuong/src/providers/app_providers.dart';
import 'package:hop_phuong/src/ui/dialogs/round_dialog.dart';
import 'package:hop_phuong/src/utils/ui_helpers.dart';

Future<void> openRoundDialog(
  BuildContext context,
  WidgetRef ref, {
  required AppRepository repository,
  required Pool pool,
  required Round round,
}) async {
  final members = await repository.getPoolMembers(pool.id);
  final allRounds = await repository.getRoundsForPool(pool.id);
  final usedWinnerIds = allRounds
      .where((item) => item.id != round.id && item.winnerId != null)
      .map((item) => item.winnerId!)
      .toSet();
  final availableMembers = members
      .where(
        (member) =>
            member.id == round.winnerId || !usedWinnerIds.contains(member.id),
      )
      .toList(growable: false);

  if (!context.mounted) {
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => RoundDialog(
      pool: pool,
      round: round,
      members: availableMembers,
      onSave: (winnerId, bidAmount) async {
        await repository.saveRoundResult(
          roundId: round.id,
          winnerId: winnerId,
          bidAmount: bidAmount,
        );
        refreshAll(ref);
      },
    ),
  );
}

Future<void> openPaymentsSheet(
  BuildContext context,
  WidgetRef ref, {
  required AppRepository repository,
  required Pool pool,
  required Round round,
}) async {
  final members = await repository.getPoolMembers(pool.id);
  final statuses = await repository.getPaymentStatusesForRound(round.id);
  final statusMap = {
    for (final status in statuses) status.userId: status.isPaid,
  };

  if (!context.mounted) {
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      String searchQuery = '';
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final filteredMembers = members.where((m) {
            if (searchQuery.isEmpty) return true;
            final query = removeDiacritics(searchQuery.toLowerCase());
            final name = removeDiacritics(m.name.toLowerCase());
            final phone = m.phone.toLowerCase();
            return name.contains(query) || phone.contains(query);
          }).toList();

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 4,
              bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thanh toán tháng thứ ${round.roundNumber}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên hoặc số điện thoại…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  ),
                  onChanged: (value) {
                    setSheetState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                  ),
                  child: filteredMembers.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text('Không tìm thấy thành viên nào'),
                          ),
                        )
                      : ListView.separated(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: filteredMembers.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final member = filteredMembers[index];
                            final paid = statusMap[member.id] ?? false;
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: paid,
                              onChanged: (checked) async {
                                final confirm = await showConfirmDialog(
                                  context,
                                  'Xác nhận cập nhật',
                                  'Bạn có chắc chắn muốn cập nhật trạng thái thanh toán cho "${member.name}"?',
                                );
                                if (!confirm) return;

                                await repository.setPaymentStatus(
                                  userId: member.id,
                                  roundId: round.id,
                                  isPaid: checked ?? false,
                                );
                                setSheetState(() {
                                  statusMap[member.id] = checked ?? false;
                                });
                                ref.invalidate(roundsProvider);
                              },
                              title: Text(
                                member.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(member.phone),
                                ],
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
}

Future<DateTime?> pickMonthYear(
  BuildContext context,
  DateTime initial, {
  bool showDay = false,
}) async {
  var selectedDay = initial.day;
  var selectedMonth = initial.month;
  var selectedYear = initial.year;

  return showDialog<DateTime>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(showDay ? 'Chọn ngày âm lịch' : 'Chọn tháng âm lịch'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showDay) ...[
                    DropdownButtonFormField<int>(
                      value: selectedDay,
                      decoration: const InputDecoration(labelText: 'Ngày'),
                      items: [
                        for (var day = 1; day <= 30; day++)
                          DropdownMenuItem<int>(
                            value: day,
                            child: Text('Ngày $day'),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => selectedDay = value ?? selectedDay),
                    ),
                    const SizedBox(height: 12),
                  ],
                  DropdownButtonFormField<int>(
                    value: selectedMonth,
                    decoration: const InputDecoration(labelText: 'Tháng'),
                    items: [
                      for (var month = 1; month <= 12; month++)
                        DropdownMenuItem<int>(
                          value: month,
                          child: Text('Tháng $month'),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => selectedMonth = value ?? selectedMonth),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedYear,
                    decoration: const InputDecoration(labelText: 'Năm'),
                    items: [
                      for (
                        var year = DateTime.now().year - 10;
                        year <= DateTime.now().year + 10;
                        year++
                      )
                        DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year'),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => selectedYear = value ?? selectedYear),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(DateTime(selectedYear, selectedMonth, selectedDay)),
            child: const Text('Áp dụng'),
          ),
        ],
      );
    },
  );
}

Future<int?> pickLunarDay(BuildContext context, int? initial) async {
  var selectedDay = initial ?? 15;

  return showDialog<int>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Chọn ngày âm lịch họp Phường'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 320,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 30,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final isSelected = day == selectedDay;
                  final cs = Theme.of(context).colorScheme;
                  return InkWell(
                    onTap: () => setState(() => selectedDay = day),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? cs.primary : cs.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? cs.primary : cs.outlineVariant,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? cs.onPrimary : cs.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(selectedDay),
            child: const Text('Áp dụng'),
          ),
        ],
      );
    },
  );
}

void refreshAll(WidgetRef ref) {
  ref.invalidate(membersProvider);
  ref.invalidate(poolsProvider);
  ref.invalidate(roundsProvider);
  ref.invalidate(statementProvider);
}

void showSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
    ),
  );
}

String labelForUser(List<User> users, int? userId) {
  if (userId == null) {
    return 'Chưa có';
  }
  for (final user in users) {
    if (user.id == userId) {
      return user.name;
    }
  }
  return 'Thành viên #$userId';
}

String? positiveIntValidator(String? value) {
  final parsed = int.tryParse(value?.replaceAll('.', '') ?? '');
  if (parsed == null || parsed <= 0) {
    return 'Vui lòng nhập số hợp lệ';
  }
  return null;
}

Future<bool> showConfirmDialog(
  BuildContext context,
  String title,
  String content, {
  String confirmLabel = 'Đồng ý',
  String cancelLabel = 'Hủy',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

String removeDiacritics(String str) {
  const withDia =
      'áàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵđÁÀẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬÉÈẺẼẸÊẾỀỂỄỆÍÌỈĨỊÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÚÙỦŨỤƯỨỪỬỮỰÝỲỶỸỴĐ';
  const withoutDia =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }
  return str;
}

String generateMemberCode(int id, String name) {
  final numStr = (id % 100).toString().padLeft(2, '0');
  if (name.isEmpty) return 'MB$numStr';
  final normalized = removeDiacritics(name).toUpperCase();
  final parts = normalized
      .trim()
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .toList();
  String letters = '';
  if (parts.length >= 2) {
    letters = '${parts.first[0]}${parts.last[0]}';
  } else if (parts.isNotEmpty) {
    final part = parts.first;
    letters = part.length >= 2 ? part.substring(0, 2) : (part + 'X');
  } else {
    letters = 'MB';
  }
  letters = letters.replaceAll(RegExp(r'[^A-Z]'), 'X');
  if (letters.length > 2) letters = letters.substring(0, 2);
  if (letters.length < 2) letters = letters.padRight(2, 'X');

  return '$letters$numStr';
}
