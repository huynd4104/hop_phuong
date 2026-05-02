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
      return StatefulBuilder(
        builder: (context, setSheetState) {
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
                  'Thanh toán kỳ thứ ${round.roundNumber}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(pool.name),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 440),
                  child: ListView.separated(
                    primary: false,
                    shrinkWrap: true,
                    itemCount: members.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final paid = statusMap[member.id] ?? false;
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: paid,
                        onChanged: (checked) async {
                          final confirm = await showConfirmDialog(
                            context,
                            'Xác nhận cập nhật',
                            'Bạn có chắc chắn muốn cập nhật trạng thái thanh toán?',
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
                        title: Text(member.name),
                        subtitle: Text(member.phone),
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

Future<DateTime?> pickMonthYear(BuildContext context, DateTime initial) async {
  var selectedMonth = initial.month;
  var selectedYear = initial.year;

  return showDialog<DateTime>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Chọn tháng và năm âm lịch'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedMonth,
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
                    initialValue: selectedYear,
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
            ).pop(DateTime(selectedYear, selectedMonth)),
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
