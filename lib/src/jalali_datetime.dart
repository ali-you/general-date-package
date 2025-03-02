import 'calendar_interface.dart';

class JalaliDatetime extends CalendarInterface {
  /// **Private constructor**
  JalaliDatetime._(
    super.year, [
    super.month,
    super.day,
    super.hour,
    super.minute,
    super.second,
    super.millisecond,
    super.microsecond,
  ]);

  /// **Factory constructor with normalization**
  factory JalaliDatetime(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  ]) {
    return JalaliDatetime._(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    )._normalize();
  }

  /// **Factory constructor for converting from DateTime**
  factory JalaliDatetime.fromDatetime(DateTime datetime) {
    return JalaliDatetime._(
      datetime.year,
      datetime.month,
      datetime.day,
      datetime.hour,
      datetime.minute,
      datetime.second,
      datetime.millisecond,
      datetime.microsecond,
    )._toJalali();
  }

  /// **Factory constructor for converting from DateTime**
  factory JalaliDatetime.now() {
    DateTime datetime = DateTime.now();
    return JalaliDatetime._(
      datetime.year,
      datetime.month,
      datetime.day,
      datetime.hour,
      datetime.minute,
      datetime.second,
      datetime.millisecond,
      datetime.microsecond,
    )._toJalali();
  }

  /// **Calendar name**
  @override
  String get name => "Jalali";

  /// **Convert Jalali date to DateTime**
  @override
  DateTime toDatetime() {
    int jy = year;
    int jm = month;
    int jd = day;

    jy += 1595;
    int days =
        -355668 + (365 * jy) + ((jy ~/ 33) * 8) + (((jy % 33) + 3) ~/ 4) + jd;
    days += (jm < 7) ? (jm - 1) * 31 : ((jm - 7) * 30) + 186;
    int gy = 400 * (days ~/ 146097);
    days %= 146097;
    if (days > 36524) {
      days--;
      gy += 100 * (days ~/ 36524);
      days %= 36524;
      if (days >= 365) days++;
    }
    gy += 4 * (days ~/ 1461);
    days %= 1461;
    gy += (days - 1) ~/ 365;
    if (days > 365) days = (days - 1) % 365;
    int gd = days + 1;
    List<int> gm = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if ((gy % 4 == 0 && gy % 100 != 0) || (gy % 400 == 0)) gm[2] = 29;
    int i = 1;
    while (gd > gm[i]) gd -= gm[i++];
    return DateTime(gy, i, gd, hour, minute, second, millisecond, microsecond);
  }

  /// **Check if the year is a leap year**
  @override
  bool get isLeapYear {
    final List<int> leapYears = [1, 5, 9, 13, 17, 22, 26, 30];
    return leapYears.contains(year % 33);
  }

  /// **Convert from Gregorian to Jalali**
  JalaliDatetime _toJalali() {
    int gy = year;
    int gm = month;
    int gd = day;
    List<int> gDM = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    int jy;
    if (gy > 1600) {
      jy = 979;
      gy -= 1600;
    } else {
      jy = 0;
      gy -= 621;
    }
    int gy2 = (gm > 2) ? (gy + 1) : gy;
    int days =
        (365 * gy) +
        ((gy2 + 3) ~/ 4) -
        ((gy2 + 99) ~/ 100) +
        ((gy2 + 399) ~/ 400) -
        80 +
        gd;
    for (int i = 0; i < gm; ++i) days += gDM[i];
    jy += 33 * (days ~/ 12053);
    days %= 12053;
    jy += 4 * (days ~/ 1461);
    days %= 1461;
    jy += (days - 1) ~/ 365;
    if (days > 365) days = (days - 1) % 365;
    int jm = (days < 186) ? 1 + (days ~/ 31) : 7 + ((days - 186) ~/ 30);
    int jd = 1 + ((days < 186) ? (days % 31) : ((days - 186) % 30));
    return JalaliDatetime._(
      jy,
      jm,
      jd,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  /// **Normalize values (overflow handling)**
  JalaliDatetime _normalize() {
    int y = year, m = month, d = day;
    int h = hour, min = minute, s = second, ms = millisecond, us = microsecond;

    ms += us ~/ 1000;
    us %= 1000;

    s += ms ~/ 1000;
    ms %= 1000;

    min += s ~/ 60;
    s %= 60;

    h += min ~/ 60;
    min %= 60;

    d += h ~/ 24;
    h %= 24;

    while (d > _daysInJalaliMonth(y, m)) {
      d -= _daysInJalaliMonth(y, m);
      m++;
      if (m > 12) {
        m = 1;
        y++;
      }
    }

    return JalaliDatetime._(y, m, d, h, min, s, ms, us);
  }

  /// **Get days in the current month**
  @override
  int get monthLength => _daysInJalaliMonth(year, month);

  /// **Calculate weekday (0=Saturday, 6=Friday)**
  @override
  int get weekday {
    DateTime gregorian = toDatetime();
    return (gregorian.weekday) % 7;
  }

  /// **Compare Jalali dates**
  @override
  int compareTo(CalendarInterface other) {
    return toDatetime().compareTo(other.toDatetime());
  }

  /// **Helper method to get month length**
  static int _daysInJalaliMonth(int year, int month) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return _isJalaliLeapYear(year) ? 30 : 29;
  }

  /// **Check if a Jalali year is leap**
  static bool _isJalaliLeapYear(int year) {
    final List<int> leapYears = [1, 5, 9, 13, 17, 22, 26, 30];
    return leapYears.contains(year % 33);
  }

  /// **String representation**
  @override
  String toString() {
    return "JalaliDatetime: $year-$month-$day $hour:$minute:$second";
  }
}
