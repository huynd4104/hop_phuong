import 'package:flutter/material.dart';
import 'package:hop_phuong/src/models/user_entity.dart';
import 'package:hop_phuong/src/utils/ui_helpers.dart';

class UserDialog extends StatefulWidget {
  const UserDialog({required this.onSave, this.user, required this.existingUsers});

  final User? user;
  final List<User> existingUsers;
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
                decoration: const InputDecoration(
                  labelText: 'Tên thành viên',
                  hintText: 'Nhập tên thành viên',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên';
                  }
                  final trimmedName = value.trim();
                  final isDuplicate = widget.existingUsers.any((u) => 
                    u.id != widget.user?.id && 
                    u.name.trim().toLowerCase() == trimmedName.toLowerCase()
                  );
                  if (isDuplicate) {
                    return 'Tên thành viên đã tồn tại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                enabled: widget.user?.isOwner != true,
                decoration: const InputDecoration(
                  labelText: 'Điện thoại (không bắt buộc)',
                  hintText: 'Nhập số điện thoại',
                ),
                keyboardType: TextInputType.phone,
                // Validator removed for phone as it is now optional
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
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
                    await widget.onSave(_nameController.text.trim(), _phoneController.text.trim());
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _saving = false);
                    }
                  }
                },
          child: _saving 
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Text('Lưu'),
        ),
      ],
    );
  }
}


