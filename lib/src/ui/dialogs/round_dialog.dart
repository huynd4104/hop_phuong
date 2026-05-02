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

class RoundDialog extends StatefulWidget {
  const RoundDialog({required this.pool, required this.round, required this.members, required this.onSave});

  final Pool pool;
  final Round round;
  final List<User> members;
  final Future<void> Function(int winnerId, int bidAmount) onSave;

  @override
  State<RoundDialog> createState() => RoundDialogState();
}

class RoundDialogState extends State<RoundDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bidController;
  int? _winnerId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _bidController = TextEditingController(text: widget.round.bidAmount == 0 ? '' : formatSimpleMoney(widget.round.bidAmount));
    _winnerId = widget.round.winnerId;
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPot = widget.pool.baseAmount * widget.members.length;

    return AlertDialog(
      title: Text('Người thứ ${widget.round.roundNumber}'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _winnerId,
                decoration: const InputDecoration(labelText: 'Người lấy'),
                items: widget.members
                    .map(
                      (member) => DropdownMenuItem<int>(
                        value: member.id,
                        child: Text(member.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _winnerId = value),
                validator: (value) => value == null ? 'Vui lòng chọn người lấy' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bidController,
                decoration: InputDecoration(labelText: 'Số tiền đấu', helperText: 'Tổng bát: ${formatMoney(totalPot)}'),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) {
                  final parsed = int.tryParse(value?.replaceAll('.', '') ?? '');
                  if (parsed == null) {
                    return 'Vui lòng nhập số tiền đấu';
                  }
                  if (parsed > totalPot) {
                    return 'Tiền đấu không được vượt quá tổng bát';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: const Text('Hủy')),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  if (!(_formKey.currentState?.validate() ?? false) || _winnerId == null) {
                    return;
                  }

                  if (widget.round.winnerId != null || widget.round.bidAmount > 0) {
                    final confirm = await showConfirmDialog(
                      context,
                      'Xác nhận cập nhật',
                      'Bạn có chắc chắn muốn cập nhật kết quả người này?',
                    );
                    if (!confirm || !mounted) return;
                  }

                  setState(() => _saving = true);
                  try {
                    await widget.onSave(_winnerId!, int.parse(_bidController.text.replaceAll('.', '')));
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _saving = false);
                    }
                  }
                },
          child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Lưu'),
        ),
      ],
    );
  }
}

