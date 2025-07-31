import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef AgroNexusGetter<T> = T Function();

String formatDateToUser({required String date}) {
  DateTime parsedDate = DateTime.parse(date);
  String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
  return formattedDate;
}

String formatDateTimeToUser({required String datetime}) {
  DateTime parsedDate = DateTime.parse(datetime);
  String formattedDate = DateFormat('dd/MM/yyyy hh:mm').format(parsedDate);
  return formattedDate;
}

String formatDateToServer({required String date}) {
  DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(date);
  String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
  return formattedDate;
}

String formatDateTimeToServer({required String datetime}) {
  DateTime parsedDate = DateFormat('dd/MM/yyyy hh:mm').parse(datetime);
  String formattedDate = DateFormat('yyyy-MM-dd hh:mm').format(parsedDate);
  return formattedDate;
}

DateTime? parseDateTimeServer({String? datetime}) => datetime == null
    ? null
    : datetime.isEmpty
        ? null
        : DateTime.parse(datetime);

class AgroNexusColors {
  static final Color primary = Colors.green;
}
