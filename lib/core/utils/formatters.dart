import 'package:intl/intl.dart';

abstract final class AppFormatters {
  static String currency(num amount, {String currencyCode = 'EUR'}) {
    final formatter = NumberFormat.currency(
      locale: 'en',
      symbol: _currencySymbol(currencyCode),
      decimalDigits: 2,
    );

    return formatter.format(amount);
  }

  static String shortDate(DateTime value) {
    return DateFormat('MMM d').format(value);
  }

  static String shortDateWithYear(DateTime value) {
    return DateFormat('MMM d, yyyy').format(value);
  }

  static String dateRange(DateTime start, DateTime end) {
    return '${shortDate(start)} - ${shortDateWithYear(end)}';
  }

  static String initials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  static String _currencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'EUR':
        return '\u20AC';
      case 'USD':
        return '\$';
      case 'GBP':
        return '\u00A3';
      default:
        return '$currencyCode ';
    }
  }
}
