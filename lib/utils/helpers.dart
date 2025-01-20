// String formatPrice(double price) => '\$${price.toStringAsFixed(2)}';

// lib/utils/currency_utils.dart

import 'package:intl/intl.dart';

class CurrencyUtils {
  // Formats a given price to Indian Rupee format
  static String formatPrice(double price) {
    final NumberFormat formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return formatter.format(price);
  }
}
