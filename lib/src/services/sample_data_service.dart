import 'dart:math';
import '../data/app_repository.dart';
import 'package:lunar_calendar/lunar_calendar.dart';

class SampleDataService {
  const SampleDataService();

  Future<void> seedIfEmpty(AppRepository repository) async {
    // Always clear for a clean state during this development phase
    await repository.clearAll();
    
    final users = await repository.getUsers();
    final pools = await repository.getPools();
    if (users.length > 1 || pools.isNotEmpty) {
      return;
    }

    final random = Random();
    
    // 1. Create at least 50 users
    for (var i = 1; i <= 50; i++) {
      final name = _generateVietnameseName(i);
      final phone = '090${(1000000 + i).toString()}';
      await repository.saveUser(name: name, phone: phone);
    }

    // Fetch all users to get the actual persisted IDs
    final allUsers = await repository.getUsers();
    final createdUserIds = allUsers.map((u) => u.id).toList();

    // 2. Define 10 pool names
    final poolNames = [
      'Phường Tân Phát', 'Phường Hạnh Phúc', 'Phường Kim Tiền', 'Phường An Bình',
      'Phường Phú Quý', 'Phường Thịnh Vượng', 'Phường Đại Lộc', 'Phường Tài Lộc',
      'Phường Vạn Sự', 'Phường Như Ý'
    ];

    // 3. Map each user to 5-7 random pools to satisfy the requirement
    final poolToMembers = List.generate(10, (_) => <int>[]);
    for (final userId in createdUserIds) {
      final poolCount = random.nextInt(3) + 5; // 5, 6, or 7
      final selectedPoolIndices = <int>{};
      while (selectedPoolIndices.length < poolCount) {
        selectedPoolIndices.add(random.nextInt(10));
      }
      for (final poolIdx in selectedPoolIndices) {
        poolToMembers[poolIdx].add(userId);
      }
    }

    // 4. Create 10 pools with their assigned members
    for (var i = 0; i < 10; i++) {
      final memberIds = poolToMembers[i];
      // In these pools, total rounds usually equals number of members
      final totalRounds = memberIds.length;
      final baseAmount = (random.nextInt(5) + 1) * 1000000; // 1M to 5M
      
      final meetingDay = random.nextInt(28) + 1;
      final lunarMonth = random.nextInt(3) + 1;
      final startDate = LunarCalendar.lunarToSolar(meetingDay, lunarMonth, 2026);
      
      final pool = await repository.savePool(
        name: poolNames[i],
        baseAmount: baseAmount,
        totalRounds: totalRounds,
        meetingDay: meetingDay,
        startDate: startDate,
        memberIds: memberIds,
      );

      // 5. Seed some initial round results for realism (first 1-3 rounds)
      final rounds = await repository.getRoundsForPool(pool.id);
      final owner = (await repository.getUsers()).firstWhere((u) => u.isOwner);
      final otherMemberIds = memberIds.where((id) => id != owner.id).toList();
      final shuffledMembers = otherMemberIds..shuffle(random);
      final roundsToSeed = min(3, rounds.length);
      
      for (var r = 1; r < min(roundsToSeed, shuffledMembers.length + 1); r++) {
        // Bid amount should be a reasonable fraction of baseAmount
        // Usually between 10% and 30% of baseAmount
        final bidAmount = (baseAmount * (0.1 + random.nextDouble() * 0.2)).toInt();
        final roundedBid = (bidAmount ~/ 10000) * 10000; // Round to 10k

        await repository.saveRoundResult(
          roundId: rounds[r].id,
          winnerId: shuffledMembers[r - 1],
          bidAmount: max(10000, roundedBid),
        );
      }
    }
  }

  String _generateVietnameseName(int index) {
    final names = [
      'Nguyễn Văn Hải', 'Trần Thị Hoa', 'Lê Minh Tâm', 'Phạm Quang Huy', 'Võ Hoàng Nam',
      'Hoàng Minh Anh', 'Phan Hữu Nghĩa', 'Đỗ Thị Mai', 'Vũ Đức Trọng', 'Đặng Xuân Trường',
      'Bùi Minh Quân', 'Lý Bảo Trâm', 'Đào Văn Tuấn', 'Ngô Thị Tuyết', 'Trịnh Công Sơn',
      'Hồ Hoài Nam', 'Phùng Quang Khải', 'Lâm Bảo Ngọc', 'Tô Thanh Hằng', 'Hà Văn Quyết',
      'Đinh Công Tráng', 'Đoàn Thị Thùy', 'Mai Văn Linh', 'Quách Tuấn Du', 'Lương Thế Thành',
      'Dương Hồng Nhung', 'Thái Hòa', 'Cao Minh Thắng', 'Thân Văn Hiến', 'Trần Quốc Toản',
      'Lê Văn Hưu', 'Nguyễn Thị Minh Khai', 'Phạm Hồng Thái', 'Võ Văn Kiệt', 'Phan Châu Trinh',
      'Đinh Tiên Hoàng', 'Lê Thánh Tông', 'Chu Mạnh Trinh', 'Ngô Gia Tự', 'Nguyễn Tri Phương',
      'Trần Quang Khải', 'Lý Thường Kiệt', 'Lê Hồng Phong', 'Nguyễn Huệ', 'Nguyễn Bỉnh Khiêm',
      'Võ Thị Sáu', 'Nguyễn Thái Học', 'Cao Bá Quát', 'Lương Thế Vinh', 'Nguyễn Văn Cừ'
    ];
    
    return names[(index - 1) % names.length];
  }
}
