import 'package:hive_flutter/hive_flutter.dart';

class CalculatorData {
  final mydoc = Hive.openBox('mydoc');

  //app data
  final auctionHouses = ['Phillips', 'Christie\'s', 'Sotheby\'s', 'Antiquorum'];

  final locations = {
    'Phillips': ['New York', 'London', 'Hong Kong', 'Geneva'],
    'Christie\'s': ['London', 'New York', 'Hong Kong', 'Geneva', 'Paris'],
    'Sotheby\'s': ['New York', 'Hong Kong', 'London', 'Paris', 'Geneva'],
    'Antiquorum': ['Monaco', 'Hong Kong', 'Geneva']
  };

  final currencies = {
    'New York': 'USD',
    'London': 'GBP',
    'Hong Kong': 'HKD',
    'Geneva': 'CHF',
    'Paris': 'EUR',
    'Monaco': 'EUR'
  };

  final sign = {
    'New York': '\$',
    'London': '£',
    'Hong Kong': 'HK\$',
    'Geneva': 'CHF',
    'Paris': '€',
    'Monaco': '€'
  };

  final rates = {
    'Phillips': {
      'London': [
        {'limit': 800000, 'rate': 0.27},
        {'limit': 4500000, 'rate': 0.21},
        {'limit': double.infinity, 'rate': 0.145},
      ],
      'New York': [
        {'limit': 1000000, 'rate': 0.27},
        {'limit': 6000000, 'rate': 0.21},
        {'limit': double.infinity, 'rate': 0.145},
      ],
      'Hong Kong': [
        {'limit': 7500000, 'rate': 0.27},
        {'limit': 50000000, 'rate': 0.21},
        {'limit': double.infinity, 'rate': 0.145},
      ],
      'Geneva': [
        {'limit': 1000000, 'rate': 0.27},
        {'limit': 5000000, 'rate': 0.21},
        {'limit': double.infinity, 'rate': 0.145},
      ],
    },
    'Christie\'s': {
      'London': [
        {'limit': 800000, 'rate': 0.26},
        {'limit': 4500000, 'rate': 0.21},
        {'limit': double.infinity, 'rate': 0.15},
      ],
      'New York': [
        {'limit': 1000000, 'rate': 0.26},
        {'limit': 6000000, 'rate': 0.21},
        {'limit': double.infinity, 'rate': 0.15},
      ],
      'Hong Kong': [
        {'limit': 7500000, 'rate': 0.26},
        {'limit': 50000000, 'rate': 0.21},
        {'limit': double.infinity, 'rate': 0.15},
      ],
      'Geneva': [
        {'limit': 900000, 'rate': 0.26},
        {'limit': 6000000, 'rate': 0.21},
        {'limit': double.infinity, 'rate': 0.15},
      ],
      'Paris': [
        {'limit': 800000, 'rate': 0.26},
        {'limit': 4000000, 'rate': 0.21},
        {'limit': double.infinity, 'rate': 0.15},
      ],
    },
    'Sotheby\'s': {
      'London': [
        {'limit': 5000000, 'rate': 0.20},
        {'limit': double.infinity, 'rate': 0.10},
      ],
      'New York': [
        {'limit': 6000000, 'rate': 0.20},
        {'limit': double.infinity, 'rate': 0.10},
      ],
      'Hong Kong': [
        {'limit': 50000000, 'rate': 0.20},
        {'limit': double.infinity, 'rate': 0.10},
      ],
      'Geneva': [
        {'limit': 6000000, 'rate': 0.20},
        {'limit': double.infinity, 'rate': 0.10},
      ],
      'Paris': [
        {'limit': 5000000, 'rate': 0.20},
        {'limit': double.infinity, 'rate': 0.10},
      ],
    },
    'Antiquorum': {
      'Monaco': [
        {'limit': 1000000, 'rate': 0.26},
        {'limit': 5000000, 'rate': 0.21},
        {'limit': double.infinity, 'rate': 0.16},
      ],
      'Hong Kong': [
        {'limit': 8500000, 'rate': 0.26},
        {'limit': 42500000, 'rate': 0.20},
        {'limit': double.infinity, 'rate': 0.15},
      ],
      'Geneva': [
        {'limit': 1000000, 'rate': 0.26},
        {'limit': 5000000, 'rate': 0.20},
        {'limit': double.infinity, 'rate': 0.15},
      ],
    },
  };
}
