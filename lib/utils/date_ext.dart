extension DateExt on DateTime {
  ///
  ///时间格式
  ///
  String format({String format = 'yyyy-MM-dd HH:mm:ss'}) {
    final y = _fourDigits(year);
    final m = _twoDigits(month);
    final d = _twoDigits(day);
    final h = _twoDigits(hour);
    final min = _twoDigits(minute);
    final sec = _twoDigits(second);

    return format
        .replaceAll('yyyy', y)
        .replaceAll('MM', m)
        .replaceAll('dd', d)
        .replaceAll('HH', h)
        .replaceAll('mm', min)
        .replaceAll('ss', sec);
  }

  static String _fourDigits(int n) {
    final absN = n.abs();
    final sign = n < 0 ? '-' : '';
    if (absN >= 1000) return '$n';
    if (absN >= 100) return '${sign}0$absN';
    if (absN >= 10) return '${sign}00$absN';
    return '${sign}000$absN';
  }

  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}

extension DurationExt on Duration {
  String format({String format = 'mm:ss'}) {
    return DateTime.fromMillisecondsSinceEpoch(this.inMilliseconds)
        .format(format: format);
  }
}
