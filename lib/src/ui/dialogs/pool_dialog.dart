import 'package:hop_phuong/src/utils/ui_helpers.dart';
import 'package:lunar_calendar/lunar_calendar.dart';
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

class PoolDialog extends StatefulWidget {
  const PoolDialog({
    required this.users,
    required this.onSave,
    this.pool,
    this.initialMemberIds = const <int>[],
  });

  final Pool? pool;
  final List<User> users;
  final List<int> initialMemberIds;
  final Future<void> Function(
    String name,
    int baseAmount,
    int totalRounds,
    int meetingDay,
    DateTime startDate,
    List<int> memberIds,
  )
  onSave;

  @override
  State<PoolDialog> createState() => PoolDialogState();
}

class PoolDialogState extends State<PoolDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _baseController;
  late final TextEditingController _searchController;
  String _searchQuery = '';
  late DateTime _startDate;
  late final Set<int> _selectedMemberIds;
  final _mainScrollController = ScrollController();
  final _listScrollController = ScrollController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pool?.name ?? '');
    _baseController = TextEditingController(
      text: widget.pool != null
          ? formatSimpleMoney(widget.pool!.baseAmount)
          : '',
    );
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _startDate = widget.pool?.startDate ?? DateTime.now();
    _selectedMemberIds = <int>{};
    if (widget.pool != null) {
      _selectedMemberIds.addAll(widget.initialMemberIds);
    }
    // Ensure owner is always selected
    for (final user in widget.users) {
      if (user.isOwner) {
        _selectedMemberIds.add(user.id);
        break;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseController.dispose();
    _searchController.dispose();
    _mainScrollController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  List<User> get _filteredUsers {
    if (_searchQuery.isEmpty) return widget.users;
    return widget.users
        .where(
          (user) =>
              user.name.toLowerCase().contains(_searchQuery) ||
              user.phone.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  DateTime? get _endDate {
    if (_selectedMemberIds.isEmpty) return null;
    final meetingDay = LunarCalendar.solarToLunar(_startDate).day;
    final dates = const LunarScheduleService().generateMeetingDates(
      startDate: _startDate,
      totalRounds: _selectedMemberIds.length,
      meetingDay: meetingDay,
    );
    return dates.isEmpty ? null : dates.last;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: null,
      contentPadding: const EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24,
      ), // Tăng padding top từ 20 mặc định lên để an toàn hơn
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          controller: _mainScrollController,
          child: SafeArea(
            bottom: false, // Chỉ cần quan tâm tới top khi bị đẩy lên
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 12,
                  ), // Khoảng trống cho label "Tên Phường" khi nó float lên
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Tên Phường'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Vui lòng nhập tên Phường'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _baseController,
                          decoration: const InputDecoration(
                            labelText: 'Tiền gốc (VND)',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [CurrencyInputFormatter()],
                          validator: positiveIntValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withValues(alpha: 0.3),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Tổng số người',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_selectedMemberIds.length} người',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DateInfoCard(
                              label: 'Bắt đầu (Âm)',
                              date: _startDate,
                              isLunar: true,
                              onTap: () async {
                                final lunarNow = LunarCalendar.solarToLunar(
                                  _startDate,
                                );
                                var initialDay = lunarNow.day;
                                if (lunarNow.month == 2 && initialDay > 28)
                                  initialDay = 28;
                                final selected = await showDatePicker(
                                  context: context,
                                  helpText: 'CHỌN NGÀY BẮT ĐẦU (ÂM LỊCH)',
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  initialDate: DateTime(
                                    lunarNow.year,
                                    lunarNow.month,
                                    initialDay,
                                  ),
                                );
                                if (selected != null) {
                                  try {
                                    var day = selected.day;
                                    if (day > 30)
                                      day = 30; // Prevent invalid lunar day
                                    final solar = LunarCalendar.lunarToSolar(
                                      day,
                                      selected.month,
                                      selected.year,
                                    );
                                    setState(() => _startDate = solar);
                                  } catch (e) {
                                    showSnackBar(
                                      context,
                                      'Ngày âm lịch không hợp lệ.',
                                      isError: true,
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DateInfoCard(
                              label: 'Kết thúc (Âm)',
                              date: _endDate ?? _startDate,
                              isLunar: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thành viên',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${_selectedMemberIds.length} đã chọn',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (widget.users.isNotEmpty)
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Tìm kiếm (tên, SĐT)',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                    ),
                  if (widget.users.isNotEmpty) const SizedBox(height: 8),
                  widget.users.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Hãy tạo thành viên trước.'),
                          ),
                        )
                      : _filteredUsers.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Không tìm thấy thành viên.'),
                          ),
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              value: _selectedMemberIds.contains(user.id),
                              onChanged: user.isOwner
                                  ? null
                                  : (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _selectedMemberIds.add(user.id);
                                        } else {
                                          _selectedMemberIds.remove(user.id);
                                        }
                                      });
                                    },
                              title: Row(
                                children: [
                                  Text(user.name),
                                  if (user.isOwner) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.stars_rounded,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Text(user.phone),
                            );
                          },
                        ),
                ],
              ),
            ),
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
                  if (_selectedMemberIds.isEmpty) {
                    showSnackBar(
                      context,
                      'Chọn ít nhất một thành viên',
                      isError: true,
                    );
                    return;
                  }

                  if (widget.pool != null) {
                    final confirm = await showConfirmDialog(
                      context,
                      'Xác nhận cập nhật',
                      'Bạn có chắc chắn muốn cập nhật thông tin Phường này?',
                    );
                    if (!confirm || !mounted) return;
                  }

                  setState(() => _saving = true);
                  try {
                    final meetingDay = LunarCalendar.solarToLunar(
                      _startDate,
                    ).day;
                    await widget.onSave(
                      _nameController.text,
                      int.parse(_baseController.text.replaceAll('.', '')),
                      _selectedMemberIds.length,
                      meetingDay,
                      _startDate,
                      _selectedMemberIds.toList(growable: false),
                    );
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
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lưu'),
        ),
      ],
    );
  }
}
