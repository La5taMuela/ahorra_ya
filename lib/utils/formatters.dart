import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'es_CL',
    symbol: '\$',
    decimalDigits: 0,
  );

  static final NumberFormat decimalFormatter = NumberFormat('#,##0.0', 'es_CL');

  static String formatCurrency(double amount) {
    return currencyFormatter.format(amount);
  }

  static String formatDecimal(double number) {
    return decimalFormatter.format(number);
  }

  static String formatMonths(double months) {
    if (months < 0) return 'Meta no alcanzable';
    if (months < 1) return '${(months * 30).round()} días';
    if (months < 12) return '${months.round()} meses';
    
    final years = (months / 12).floor();
    final remainingMonths = (months % 12).round();
    
    if (remainingMonths == 0) {
      return '$years ${years == 1 ? 'año' : 'años'}';
    }
    
    return '$years ${years == 1 ? 'año' : 'años'} y $remainingMonths ${remainingMonths == 1 ? 'mes' : 'meses'}';
  }
}
