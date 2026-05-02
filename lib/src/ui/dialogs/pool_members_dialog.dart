import 'package:flutter/material.dart';
import 'package:hop_phuong/src/models/user_entity.dart';
import 'package:hop_phuong/src/models/pool_entity.dart';
import 'package:hop_phuong/src/models/round_entity.dart';
import 'package:hop_phuong/src/utils/formatters.dart';

class PoolMembersDialog extends StatefulWidget {
  final Pool pool;
  final List<User> members;
  final List<Round> rounds;

  const PoolMembersDialog({
    super.key,
    required this.pool,
    required this.members,
    required this.rounds,
  });

  @override
  State<PoolMembersDialog> createState() => _PoolMembersDialogState();
}

class _PoolMembersDialogState extends State<PoolMembersDialog> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<int, DateTime> get _winDates {
    final map = <int, DateTime>{};
    for (final r in widget.rounds) {
      if (r.winnerId != null) {
        map[r.winnerId!] = r.date;
      }
    }
    return map;
  }

  List<User> get _sortedAndFilteredMembers {
    final winDates = _winDates;
    final members = List<User>.from(widget.members);

    // Sort: Won members first (by date), then non-won members
    members.sort((a, b) {
      final dateA = winDates[a.id];
      final dateB = winDates[b.id];

      if (dateA != null && dateB != null) {
        return dateA.compareTo(dateB); // Oldest first
      }
      if (dateA != null) return -1;
      if (dateB != null) return 1;

      // Both haven't won, sort by name or owner status
      if (a.isOwner) return -1;
      if (b.isOwner) return 1;
      return a.name.compareTo(b.name);
    });

    if (_query.isEmpty) return members;

    final lowQuery = _query.toLowerCase();
    return members.where((m) {
      return m.name.toLowerCase().contains(lowQuery) ||
          m.phone.toLowerCase().contains(lowQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final winDates = _winDates;
    final filteredMembers = _sortedAndFilteredMembers;

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc SĐT...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.clear_rounded),
                      )
                    : null,
                filled: true,
                fillColor: cs.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: 400,
        height: 500,
        child: filteredMembers.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 48, color: cs.outlineVariant),
                    const SizedBox(height: 12),
                    Text(
                      'Không tìm thấy thành viên',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: filteredMembers.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 56),
                itemBuilder: (context, index) {
                  final m = filteredMembers[index];
                  final winDate = winDates[m.id];
                  final hasWon = winDate != null;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: hasWon
                          ? Colors.green.withValues(alpha: 0.1)
                          : cs.primaryContainer.withValues(alpha: 0.5),
                      child: hasWon
                          ? const Icon(Icons.check_circle_rounded,
                              color: Colors.green, size: 20)
                          : Text(
                              m.name.characters.first.toUpperCase(),
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          m.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (m.isOwner) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.stars_rounded,
                              color: Colors.amber, size: 16),
                        ],
                      ],
                    ),
                    subtitle: Text(m.phone),
                    trailing: hasWon
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                          Colors.green.withValues(alpha: 0.2)),
                                ),
                                child: const Text(
                                  'Đã hốt',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatLunarDate(winDate),
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          )
                        : null,
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
