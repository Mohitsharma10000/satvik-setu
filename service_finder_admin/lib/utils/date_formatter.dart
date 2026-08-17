import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  static String format(dynamic date) {
    if (date == null) return 'N/A';
    DateTime dateTime;
    if (date is Timestamp) {
      dateTime = date.toDate();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return date.toString();
    }
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }
}
