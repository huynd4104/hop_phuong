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

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersProvider);
    final query = ref.watch(memberSearchProvider);
    final cs = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 8, isMobile ? 16 : 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên hoặc điện thoại…',
                    prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                    hintStyle: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  onChanged: (v) => ref.read(memberSearchProvider.notifier).state = v,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _openUserDialog(context, ref),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: Text(isMobile ? 'Thêm' : 'Thêm thành viên'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: membersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(membersProvider)),
              data: (members) {
                if (members.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline_rounded,
                    title: query.isEmpty ? 'Chưa có thành viên nào' : 'Không tìm thấy thành viên',
                    subtitle: query.isEmpty ? 'Nhấn "Thêm thành viên" để bắt đầu tạo Phường.' : 'Hãy thử từ khóa khác.',
                  );
                }
                return ListView.separated(
                  controller: _scrollController,
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final m = members[i];
                    final initials = m.name.isEmpty ? '?' : m.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
                    final hue = (m.name.hashCode % 6);
                    final avatarColors = [
                      [const Color(0xFF1A73E8), const Color(0xFF4FC3F7)],
                      [const Color(0xFF0D7A6F), const Color(0xFF4DB6AC)],
                      [const Color(0xFFE53935), const Color(0xFFFF8A80)],
                      [const Color(0xFF7B1FA2), const Color(0xFFCE93D8)],
                      [const Color(0xFFF57C00), const Color(0xFFFFCC80)],
                      [const Color(0xFF2E7D32), const Color(0xFFA5D6A7)],
                    ];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _showParticipatingPools(context, ref, m),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: avatarColors[hue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                      if (m.isOwner) ...[
                                        const SizedBox(width: 4),
                                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 18),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.phone_outlined, size: 13, color: cs.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Text(m.phone, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (!m.isOwner) ...[
                              IconButton(
                                tooltip: 'Sửa',
                                onPressed: () => _openUserDialog(context, ref, user: m),
                                icon: Icon(Icons.edit_rounded, color: cs.primary, size: 20),
                                style: IconButton.styleFrom(backgroundColor: cs.primaryContainer.withValues(alpha: 0.5)),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                tooltip: 'Xóa',
                                onPressed: () async {
                                  final confirm = await showConfirmDialog(
                                    context,
                                    'Xóa thành viên',
                                    'Bạn có chắc chắn muốn xóa thành viên "${m.name}" không? Hành động này không thể hoàn tác.',
                                    isDestructive: true,
                                  );
                                  if (!confirm || !context.mounted) return;

                                  final repo = await ref.read(appRepositoryProvider.future);
                                  try {
                                    await repo.deleteUser(m.id);
                                    refreshAll(ref);
                                    if (context.mounted) showSnackBar(context, 'Đã xóa thành viên');
                                  } catch (e) {
                                    if (context.mounted) showSnackBar(context, e.toString(), isError: true);
                                  }
                                },
                                icon: Icon(Icons.delete_rounded, color: cs.error, size: 20),
                                style: IconButton.styleFrom(backgroundColor: cs.errorContainer.withValues(alpha: 0.4)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openUserDialog(BuildContext context, WidgetRef ref, {User? user}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => UserDialog(user: user, onSave: (name, phone) async {
        final repo = await ref.read(appRepositoryProvider.future);
        await repo.saveUser(id: user?.id, name: name, phone: phone);
        refreshAll(ref);
      }),
    );
  }

  void _showParticipatingPools(BuildContext context, WidgetRef ref, User user) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Phường của ${user.name}'),
        content: SizedBox(
          width: 400,
          child: FutureBuilder<List<Pool>>(
            future: ref.read(appRepositoryProvider).maybeWhen(
              data: (repo) => repo.getPoolsForUser(user.id),
              orElse: () => Future.value([]),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
              }
              final pools = snapshot.data ?? [];
              if (pools.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Thành viên này chưa tham gia Phường nào.', textAlign: TextAlign.center),
                );
              }
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: pools.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final pool = pools[index];
                    return ListTile(
                      title: Text(pool.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Gốc ${formatMoney(pool.baseAmount)} · ${pool.totalRounds} kỳ'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).pop();
                        ref.read(selectedPoolIdProvider.notifier).state = pool.id;
                        ref.read(selectedTabProvider.notifier).state = 2; // Rounds tab
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Đóng')),
        ],
      ),
    );
  }
}

