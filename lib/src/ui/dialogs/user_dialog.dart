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
import 'package:hop_phuong/src/utils/ui_helpers.dart';

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

class UserDialog extends StatefulWidget {
  const UserDialog({required this.onSave, this.user});

  final User? user;
  final Future<void> Function(String name, String phone) onSave;

  @override
  State<UserDialog> createState() => UserDialogState();
}

class UserDialogState extends State<UserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Thêm thành viên' : 'Sửa thành viên'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: widget.user?.isOwner != true,
                decoration: const InputDecoration(labelText: 'Tên thành viên'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                enabled: widget.user?.isOwner != true,
                decoration: const InputDecoration(labelText: 'Điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập số điện thoại' : null,
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
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  
                  if (widget.user != null) {
                    final confirm = await showConfirmDialog(
                      context,
                      'Xác nhận cập nhật',
                      'Bạn có chắc chắn muốn cập nhật thông tin thành viên này?',
                    );
                    if (!confirm || !mounted) return;
                  }
                  
                  setState(() => _saving = true);
                  try {
                    await widget.onSave(_nameController.text, _phoneController.text);
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

