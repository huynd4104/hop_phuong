import 'package:lunar_calendar/lunar_calendar.dart';

class LunarScheduleService {
  const LunarScheduleService();

  List<DateTime> generateMeetingDates({
    required DateTime startDate,
    required int totalRounds,
    required int meetingDay,
  }) {
    if (totalRounds <= 0) {
      return <DateTime>[];
    }

    final normalizedStart = _dateOnly(startDate);
    var monthStart = _findCurrentMonthStart(normalizedStart);
    final dates = <DateTime>[];

    while (dates.length < totalRounds) {
      final monthLength = _lunarMonthLength(monthStart);
      final targetDay = meetingDay.clamp(1, monthLength);
      final candidate = monthStart.add(Duration(days: targetDay - 1));

      if (!candidate.isBefore(normalizedStart)) {
        dates.add(candidate);
      }

      monthStart = monthStart.add(Duration(days: monthLength));
    }

    return dates;
  }

  DateTime _findCurrentMonthStart(DateTime startDate) {
    final lunar = LunarCalendar.solarToLunar(startDate);
    final candidate = LunarCalendar.lunarToSolar(
      1,
      lunar.month,
      lunar.year,
      isLeapMonth: lunar.isLeapMonth,
    );
    return _dateOnly(candidate);
  }

  int _lunarMonthLength(DateTime monthStart) {
    final base = _dateOnly(monthStart);
    for (var day = 1; day <= 40; day++) {
      final candidate = base.add(Duration(days: day));
      final lunar = LunarCalendar.solarToLunar(candidate);
      if (lunar.day == 1) {
        return day;
      }
    }
    return 29;
  }

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);
}
