import 'package:timeago/timeago.dart' show LookupMessages;

/// Uzbek Latin timeago messages
class UzMessages implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => 'oldin';
  @override
  String suffixFromNow() => 'keyin';
  @override
  String lessThanOneMinute(int seconds) => 'hozir';
  @override
  String aboutAMinute(int minutes) => '1 daqiqa';
  @override
  String minutes(int minutes) => '$minutes daqiqa';
  @override
  String aboutAnHour(int minutes) => '1 soat';
  @override
  String hours(int hours) => '$hours soat';
  @override
  String aDay(int hours) => '1 kun';
  @override
  String days(int days) => '$days kun';
  @override
  String aboutAMonth(int days) => '1 oy';
  @override
  String months(int months) => '$months oy';
  @override
  String aboutAYear(int year) => '1 yil';
  @override
  String years(int years) => '$years yil';
  @override
  String wordSeparator() => ' ';
}
