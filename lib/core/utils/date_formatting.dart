// This file turn a DateTime into short text for showing on screen, like
// "2:30 PM" or "Mon" or "12/1/24".
import 'package:intl/intl.dart';

class DateFormatting {
  const DateFormatting._();

  static String chatListTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final isToday =
        now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day;
    if (isToday) return DateFormat.jm().format(dateTime);

    final daysAgo = now.difference(dateTime).inDays;
    if (daysAgo < 7) return DateFormat.E().format(dateTime);

    return DateFormat.yMd().format(dateTime);
  }

  static String messageTime(DateTime dateTime) =>
      DateFormat.jm().format(dateTime);
}
