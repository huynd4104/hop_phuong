import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lunar_calendar/lunar_calendar.dart';

final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
final NumberFormat _simpleCurrencyFormat = NumberFormat.decimalPattern('vi_VN');
final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
final DateFormat monthYearFormat = DateFormat('MM/yyyy');

String formatMoney(int amount) => currencyFormat.format(amount);

String formatSimpleMoney(int amount) => _simpleCurrencyFormat.format(amount);

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    final int value = int.parse(cleanText);
    final String formattedText = _simpleCurrencyFormat.format(value);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

String formatSolarDate(DateTime date) => dateFormat.format(date);

String formatMonthYear(DateTime date) => monthYearFormat.format(date);

String formatLunarDate(DateTime date) {
  final lunar = LunarCalendar.solarToLunar(date);
  final day = lunar.day.toString().padLeft(2, '0');
  final month = lunar.month.toString().padLeft(2, '0');
  final leap = lunar.isLeapMonth ? ' (Nhuận)' : '';
  return '$day/$month/${lunar.year}$leap';
}

String formatLunarMonthYear(DateTime date) {
  final lunar = LunarCalendar.solarToLunar(date);
  final month = lunar.month.toString().padLeft(2, '0');
  final leap = lunar.isLeapMonth ? ' (Nhuận)' : '';
  return '$month/${lunar.year}$leap';
}
