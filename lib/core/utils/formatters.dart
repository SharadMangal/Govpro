import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Formats numbers to Indian Rupee (INR) and simplifies large figures into Lakhs / Crores.
  /// Example: 350000000 -> "₹35.00 Cr"
  static String formatCurrency(double amount) {
    if (amount >= 10000000) {
      double crores = amount / 10000000;
      return '₹${crores.toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      double lakhs = amount / 100000;
      return '₹${lakhs.toStringAsFixed(2)} Lakh';
    } else {
      return _currencyFormat.format(amount);
    }
  }

  /// Formats currency with full number representation.
  /// Example: 350000000 -> "₹35,00,00,000"
  static String formatFullCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Formats date to a human-readable string.
  /// Example: DateTime(2026, 12, 30) -> "30 Dec 2026"
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Formats date to a short human-readable string.
  /// Example: DateTime(2026, 12, 30) -> "Dec 26"
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM yy').format(date);
  }

  /// Formats a percentage.
  /// Example: 65.5 -> "65.5%"
  static String formatPercentage(double percent) {
    return '${percent.toStringAsFixed(1)}%';
  }
}
