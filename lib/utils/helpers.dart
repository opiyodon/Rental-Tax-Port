import 'package:intl/intl.dart';

class Helpers {
  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: 'KES').format(amount);
  }
}