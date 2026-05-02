import 'dart:math';

class LunarDate {
  const LunarDate({
    required this.day,
    required this.month,
    required this.year,
    required this.isLeapMonth,
  });

  final int day;
  final int month;
  final int year;
  final bool isLeapMonth;

  @override
  String toString() {
    final leapLabel = isLeapMonth ? ' leap' : '';
    return '$day/$month/$year$leapLabel';
  }
}

class LunarCalendar {
  static const double vietnamTimeZone = 7.0;

  static LunarDate solarToLunar(
    DateTime solarDate, {
    double timeZone = vietnamTimeZone,
  }) {
    final dayNumber = _julianDayFromDate(solarDate.day, solarDate.month, solarDate.year);
    final k = ((dayNumber - 2415021.076998695) / 29.530588853).floor();
    var monthStart = _getNewMoonDay(k + 1, timeZone);
    if (monthStart > dayNumber) {
      monthStart = _getNewMoonDay(k, timeZone);
    }

    var lunarYear = solarDate.year;
    late final int a11;
    late final int b11;
    if (monthStart >= _getLunarMonth11(solarDate.year, timeZone)) {
      a11 = _getLunarMonth11(solarDate.year, timeZone);
      b11 = _getLunarMonth11(solarDate.year + 1, timeZone);
    } else {
      lunarYear = solarDate.year - 1;
      a11 = _getLunarMonth11(solarDate.year - 1, timeZone);
      b11 = _getLunarMonth11(solarDate.year, timeZone);
    }

    final lunarDay = dayNumber - monthStart + 1;
    final diff = ((monthStart - a11) / 29).floor();
    var lunarMonth = diff + 11;
    var lunarLeap = false;

    if (b11 - a11 > 365) {
      final leapMonthDiff = _getLeapMonthOffset(a11, timeZone);
      if (diff >= leapMonthDiff) {
        lunarMonth = diff + 10;
        if (diff == leapMonthDiff) {
          lunarLeap = true;
        }
      }
    }

    if (lunarMonth > 12) {
      lunarMonth -= 12;
    }
    if (lunarMonth < 11) {
      lunarYear += 1;
    }

    return LunarDate(
      day: lunarDay,
      month: lunarMonth,
      year: lunarYear,
      isLeapMonth: lunarLeap,
    );
  }

  static DateTime lunarToSolar(
    int lunarDay,
    int lunarMonth,
    int lunarYear, {
    bool isLeapMonth = false,
    double timeZone = vietnamTimeZone,
  }) {
    late final int a11;
    late final int b11;
    if (lunarMonth < 11) {
      a11 = _getLunarMonth11(lunarYear - 1, timeZone);
      b11 = _getLunarMonth11(lunarYear, timeZone);
    } else {
      a11 = _getLunarMonth11(lunarYear, timeZone);
      b11 = _getLunarMonth11(lunarYear + 1, timeZone);
    }

    var offset = lunarMonth - 11;
    if (offset < 0) {
      offset += 12;
    }

    if (b11 - a11 > 365) {
      final leapMonthDiff = _getLeapMonthOffset(a11, timeZone);
      if (isLeapMonth && offset != leapMonthDiff - 1) {
        throw ArgumentError('Invalid leap month for $lunarMonth/$lunarYear');
      }
      if (isLeapMonth || offset >= leapMonthDiff) {
        offset += 1;
      }
    } else if (isLeapMonth) {
      throw ArgumentError('Year $lunarYear does not contain a leap month');
    }

    final monthStart = _getNewMoonDay(
      ((a11 - 2415021.076998695) / 29.530588853).floor() + offset,
      timeZone,
    );
    return _julianDayToDate(monthStart + lunarDay - 1);
  }

  static String formatSolar(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  static String formatLunar(LunarDate date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final leap = date.isLeapMonth ? ' (Nhuan)' : '';
    return '$day/$month/${date.year}$leap';
  }

  static int _julianDayFromDate(int day, int month, int year) {
    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() - (y / 100).floor() + (y / 400).floor() - 32045;
  }

  static DateTime _julianDayToDate(int julianDay) {
    var a = julianDay + 32044;
    final b = ((4 * a + 3) / 146097).floor();
    a = a - ((146097 * b) / 4).floor();
    final c = ((4 * a + 3) / 1461).floor();
    a = a - ((1461 * c) / 4).floor();
    final m = ((5 * a + 2) / 153).floor();
    final day = a - ((153 * m + 2) / 5).floor() + 1;
    final month = m + 3 - 12 * (m / 10).floor();
    final year = 100 * b + c - 4800 + (m / 10).floor();
    return DateTime(year, month, day);
  }

  static int _getNewMoonDay(int k, double timeZone) {
    return (_newMoon(k) + 0.5 + timeZone / 24).floor();
  }

  static int _getSunLongitude(int julianDay, double timeZone) {
    return (_sunLongitude(julianDay.toDouble() - 0.5 - timeZone / 24) / pi * 6).floor();
  }

  static int _getLunarMonth11(int year, double timeZone) {
    final off = _julianDayFromDate(31, 12, year) - 2415021;
    final k = (off / 29.530588853).floor();
    var nm = _getNewMoonDay(k, timeZone);
    final sunLong = _getSunLongitude(nm, timeZone);
    if (sunLong >= 9) {
      nm = _getNewMoonDay(k - 1, timeZone);
    }
    return nm;
  }

  static int _getLeapMonthOffset(int a11, double timeZone) {
    final k = ((a11 - 2415021.076998695) / 29.530588853).floor() + 1;
    var last = 0;
    var arc = _getSunLongitude(_getNewMoonDay(k, timeZone), timeZone);
    var i = 1;
    do {
      last = arc;
      i += 1;
      arc = _getSunLongitude(_getNewMoonDay(k + i - 1, timeZone), timeZone);
    } while (arc != last && i < 15);
    return i - 1;
  }

  static double _newMoon(int k) {
    final t = k / 1236.85;
    final t2 = t * t;
    final t3 = t2 * t;
    const dr = pi / 180;

    var jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * t2 - 0.000000155 * t3;
    jd1 += 0.00033 * sin((166.56 + 132.87 * t - 0.009173 * t2) * dr);

    final m = 359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3;
    final mpr = 306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3;
    final f = 21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3;

    final c1 = (0.1734 - 0.000393 * t) * sin(m * dr)
        + 0.0021 * sin(2 * m * dr)
        - 0.4068 * sin(mpr * dr)
        + 0.0161 * sin(2 * mpr * dr)
        - 0.0004 * sin(3 * mpr * dr)
        + 0.0104 * sin(2 * f * dr)
        - 0.0051 * sin((m + mpr) * dr)
        - 0.0074 * sin((m - mpr) * dr)
        + 0.0004 * sin((2 * f + m) * dr)
        - 0.0004 * sin((2 * f - m) * dr)
        - 0.0006 * sin((2 * f + mpr) * dr)
        + 0.0010 * sin((2 * f - mpr) * dr)
        + 0.0005 * sin((2 * mpr + m) * dr);

    return jd1 + c1;
  }

  static double _sunLongitude(double jdn) {
    final t = (jdn - 2451545.0) / 36525;
    final t2 = t * t;
    final dr = pi / 180;
    final m = 357.52910 + 35999.05030 * t - 0.0001559 * t2 - 0.00000048 * t * t2;
    final l0 = 280.46645 + 36000.76983 * t + 0.0003032 * t2;
    final dl = (1.914600 - 0.004817 * t - 0.000014 * t2) * sin(dr * m)
        + (0.019993 - 0.000101 * t) * sin(2 * dr * m)
        + 0.000290 * sin(3 * dr * m);
    var l = (l0 + dl) * dr;
    l = l - 2 * pi * (l / (2 * pi)).floorToDouble();
    return l;
  }
}