import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  final String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/';
  final Map<String, Map<String, double>> _cachedRates = {};

  Future<double> getConversionRate({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    // Check if the rates are cached for the fromCurrency
    if (_cachedRates.containsKey(fromCurrency) &&
        _cachedRates[fromCurrency]!.containsKey(toCurrency)) {
      return _convert(amount, fromCurrency, toCurrency);
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl$fromCurrency'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;

        if (rates.containsKey(toCurrency)) {
          _cachedRates.putIfAbsent(fromCurrency, () => {}).addAll(
              rates.map((key, value) => MapEntry(key, value.toDouble())));
          return _convert(amount, fromCurrency, toCurrency);
        } else {
          throw Exception('Target currency not found');
        }
      } else {
        throw Exception('Failed to load conversion rates');
      }
    } catch (e) {
      // Handle network errors and unexpected issues
      throw Exception('Error: $e');
    }
  }

  double _convert(double amount, String fromCurrency, String toCurrency) {
    final rateFrom = _cachedRates[fromCurrency]?[toCurrency] ?? 1.0;
    return amount * rateFrom;
  }
}
