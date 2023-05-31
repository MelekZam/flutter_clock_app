import 'package:intl/intl.dart' as intl;

class TimeFormatter {
  static String getTime(DateTime time, String hourFormat) {
    String formatString = hourFormat == '12-Hour' ? 'hh:mm aa' : 'HH:mm';
    final dateFormat = intl.DateFormat(formatString);
    return dateFormat.format(time);
  }

  // static String timeFromString(String time, String hourFormat) {
  //   var hour = time.substring(1, 2);
  //   var minute = time.substring(4, 5);
  //   if (time.substring(7, 8) == 'PM') hour = (int.parse(hour) + 12).toString();
  //   return
  // }
}
