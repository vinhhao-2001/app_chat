import 'package:intl/intl.dart';

import '../constants/api_constants.dart';

String formatMessageTime(DateTime timestamp) {
  final DateFormat formatter = DateFormat(ApiConstants.dateFormat);
  final String formattedTime = formatter.format(timestamp);

  final DateTime now = DateTime.now();
  final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

  if (timestamp.year == now.year &&
      timestamp.month == now.month &&
      timestamp.day == now.day) {
    return formattedTime;
  } else if (timestamp.year == yesterday.year &&
      timestamp.month == yesterday.month &&
      timestamp.day == yesterday.day) {
    return '$formattedTime ${ApiConstants.yesterday}';
  } else {
    return '${formatter.format(timestamp)} ${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
