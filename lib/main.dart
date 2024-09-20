import 'package:hive_flutter/hive_flutter.dart';

import 'calculator_data.dart';
import 'conversion_dropdown.dart';
import 'keypad.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'currency_service.dart';
import 'text_container.dart';

void main() async {
  await Hive.initFlutter();
  runApp(const AuctionCalculator());
}

class AuctionCalculator extends StatelessWidget {
  const AuctionCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auction Calculator',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: const AuctionHomePage(),
    );
  }
}

class AuctionHomePage extends StatefulWidget {
  const AuctionHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuctionHomePageState createState() => _AuctionHomePageState();
}

class _AuctionHomePageState extends State<AuctionHomePage> {
  final mydoc = Hive.openBox('mydoc');
  CalculatorData db = CalculatorData();
  String selectedAuctionHouse = 'Christie\'s';
  String selectedLocation = 'London';
  String selectedCurrency = 'GBP';
  String selectedSymbol = '£';
  double amount = 0;
  double premium = 0;
  double total = 0;
  String convertedCurrency = 'USD';
  String convertedCurrency2 = 'EUR';
  double convertedValue = 0;
  double convertedValue2 = 0;
  bool isLoading = false;
  bool isConverting1 = false;
  bool isConverting2 = false;
  final formatter = NumberFormat('#,##0.00');
  bool isDecimal = false;
  double decimalMultiplier = 0.1;

  bool _isVisible = false;

  final List<DropdownMenuItem<String>> currencieslist = [
    'EUR',
    'USD',
    'GBP',
    'CAD',
    'CHF',
    'HKD',
    'CNY',
    'AUD',
    'JPY',
    'INR',
    'SGD',
    'AED'
  ].map((String currency) {
    return DropdownMenuItem<String>(
      value: currency,
      child: Text(currency),
    );
  }).toList();

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  final CurrencyService _currencyService = CurrencyService();
  Map<String, double> conversionRates = {};

  double calculatePremium(String auctionHouse, String location, double amount) {
    var rateData = db.rates[auctionHouse]?[location];

    if (rateData == null) return 0;

    for (var rateTier in rateData) {
      if (amount <= rateTier['limit']!.toDouble()) {
        return amount * rateTier['rate']!.toDouble();
      }
    }
    return 0;
  }

  bool reverseMode =
      false; // Set this flag when you want to reverse the calculation
  Future<void> updateCalculations() async {
    setState(() {
      if (reverseMode) {
        // Reverse calculation: Calculate amount based on total
        var rateData = db.rates[selectedAuctionHouse]?[selectedLocation];
        if (rateData != null) {
          for (var rateTier in rateData) {
            if (total <=
                rateTier['limit']!.toDouble() *
                    (1 + rateTier['rate']!.toDouble())) {
              amount = total / (1 + rateTier['rate']!.toDouble());
              premium =
                  total - amount; // Calculate premium based on the difference
              break;
            }
          }
        }
      } else {
        // Forward calculation: Calculate total based on amount
        premium =
            calculatePremium(selectedAuctionHouse, selectedLocation, amount);
        total = amount + premium; // Calculate total
      }

      // Make sure isLoading is part of the state update
      isLoading = true;
    });

    try {
      // Conversion rate calculations (already implemented)
      await fetchConversionRate();
      await fetchConversionRate2();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error fetching conversion rate. check connection')),
      );
    } finally {
      setState(() {
        isLoading = false; // Ensure UI reflects the loading state
      });
    }
  }

  Future<void> fetchConversionRate() async {
    setState(() {
      isConverting1 = true;
      isConverting2 = true;
    });

    try {
      final rate = await _currencyService.getConversionRate(
        fromCurrency: selectedCurrency,
        toCurrency: convertedCurrency,
        amount: total,
      );
      setState(() {
        convertedValue = rate;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error fetching conversion rate. check connection')),
      );
    } finally {
      setState(() {
        isConverting1 = false;
        isConverting2 = false;
      });
    }
  }

  Future<void> fetchConversionRate2() async {
    setState(() {
      isConverting1 = true;
      isConverting2 = true;
    });

    try {
      final rate2 = await _currencyService.getConversionRate(
        fromCurrency: selectedCurrency,
        toCurrency: convertedCurrency2,
        amount: total,
      );
      setState(() {
        convertedValue2 = rate2;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error fetching conversion rate. check connection')),
      );
    } finally {
      setState(() {
        isConverting2 = false;
        isConverting1 = false;
      });
    }
  }

  void addToAmount(String digit) {
    setState(() {
      switch (digit) {
        case '.':
          isDecimal = true; // Set flag when decimal point is encountered
          break;

        case '←':
          if (isDecimal) {
            decimalMultiplier *= 10;
          } else {
            // Handle reverseMode when deleting digits
            if (reverseMode) {
              total =
                  (total / 10).floorToDouble(); // Modify total in reverse mode
            } else {
              amount = (amount / 10).floorToDouble(); // Modify amount normally
            }
          }
          isDecimal = false; // Reset decimal mode
          decimalMultiplier = 0.1; // Reset multiplier
          break;

        default:
          double parsedDigit = double.tryParse(digit) ?? 0;

          // Handle reverseMode when adding digits
          if (reverseMode) {
            switch (isDecimal) {
              case true:
                total += parsedDigit *
                    decimalMultiplier; // Modify total in reverse mode
                decimalMultiplier *= 0.1; // Move to the next decimal place
                break;

              case false:
                total =
                    total * 10 + parsedDigit; // Handle integer part for total
                break;
            }
          } else {
            switch (isDecimal) {
              case true:
                amount +=
                    parsedDigit * decimalMultiplier; // Modify amount normally
                decimalMultiplier *= 0.1; // Move to the next decimal place
                break;

              case false:
                amount =
                    amount * 10 + parsedDigit; // Handle integer part for amount
                break;
            }
          }
          break;
      }

      // Update calculations after modifying amount or total
      updateCalculations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auction Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  // Auction House Dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          label: const Text(
                            'Auction House',
                            style: TextStyle(
                                color: Color.fromARGB(255, 145, 112, 23),
                                fontWeight: FontWeight.bold),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        value: selectedAuctionHouse,
                        items: db.auctionHouses.map((String house) {
                          return DropdownMenuItem<String>(
                            value: house,
                            child: Text(house),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedAuctionHouse = newValue!;
                            selectedLocation =
                                db.locations[selectedAuctionHouse]!.first;
                            selectedCurrency = db.currencies[selectedLocation]!;
                            selectedSymbol = db.sign[selectedLocation]!;
                            updateCalculations();
                          });
                        },
                      )),
                      const SizedBox(
                        width: 20,
                      ),
                      // Location Dropdown
                      Expanded(
                          child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          label: const Text(
                            'Location',
                            style: TextStyle(
                                color: Color.fromARGB(255, 145, 112, 23),
                                fontWeight: FontWeight.bold),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                        value: selectedLocation,
                        items: db.locations[selectedAuctionHouse]!
                            .map((String location) {
                          return DropdownMenuItem<String>(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLocation = newValue!;
                            selectedCurrency = db.currencies[selectedLocation]!;
                            selectedSymbol = db.sign[selectedLocation]!;
                            updateCalculations();
                          });
                        },
                      )),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color.fromARGB(255, 145, 112, 23),
                          width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Kindly select the auction house and city from the options above',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: 90,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedCurrency,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 145, 112, 23)),
                                  ),
                                  IconButton(
                                    icon: reverseMode
                                        ? const Icon(
                                            Icons.dialpad,
                                            size: 12,
                                            color: Colors.blueGrey,
                                          )
                                        : const Icon(
                                            Icons.dialpad,
                                            size: 18,
                                            color: Colors.black,
                                          ),
                                    onPressed: () {
                                      setState(() {
                                        reverseMode =
                                            !reverseMode; // Toggle between forward and reverse
                                        amount = 0;
                                        premium = 0;
                                        total = 0;
                                        updateCalculations();
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formatter.format(amount),
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const SizedBox(
                              width: 90,
                              child: Text(
                                'Premium :',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Myoutputfield(
                                display:
                                    '$selectedSymbol ${formatter.format(premium)}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: 90,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 145, 112, 23)),
                                  ),
                                  IconButton(
                                    icon: reverseMode
                                        ? const Icon(
                                            Icons.dialpad,
                                            size: 18,
                                            color: Colors.black,
                                          )
                                        : const Icon(
                                            Icons.dialpad,
                                            size: 12,
                                            color: Colors.blueGrey,
                                          ),
                                    onPressed: () {
                                      setState(() {
                                        reverseMode =
                                            !reverseMode; // Toggle between forward and reverse
                                        amount = 0;
                                        premium = 0;
                                        total = 0;
                                        updateCalculations();
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Myoutputfield(
                                display:
                                    '$selectedSymbol ${formatter.format(total)}'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Conversion rate for the first currency
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: 90,
                              child: ConversionDropdown(
                                updateCalculations: (newValue) {
                                  setState(() {
                                    convertedCurrency =
                                        newValue; // Update the parent state
                                    updateCalculations();
                                  });
                                },
                                dropdownlist: currencieslist,
                                dropdownvalue: convertedCurrency,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Myoutputfield(
                              display: isConverting1
                                  ? 'Fetching Data...'
                                  : formatter.format(convertedValue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Conversion rate for the second currency
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _isVisible
                                ? Expanded(
                                    child: Row(
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        child: ConversionDropdown(
                                          updateCalculations: (newValue) {
                                            setState(() {
                                              convertedCurrency2 =
                                                  newValue; // Update the parent state
                                              updateCalculations();
                                            });
                                          },
                                          dropdownlist: currencieslist,
                                          dropdownvalue: convertedCurrency2,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Myoutputfield(
                                        display: isConverting2
                                            ? 'Fetching Data...'
                                            : formatter.format(convertedValue2),
                                      ),
                                    ],
                                  ))
                                : Expanded(
                                    child: GestureDetector(
                                      onTap: _toggleVisibility,
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 98, top: 7, bottom: 7),
                                          child: _isVisible
                                              ? const Text('')
                                              : const Row(
                                                  children: [
                                                    Icon(Icons.add_box,
                                                        size: 28,
                                                        color: Color.fromARGB(
                                                            255, 145, 112, 23)),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      'Add Currency',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Color.fromARGB(
                                                              255,
                                                              145,
                                                              112,
                                                              23)),
                                                    ),
                                                  ],
                                                )),
                                    ),
                                  ),
                            const SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: _toggleVisibility,
                              child: _isVisible
                                  ? const Icon(
                                      Icons.close,
                                      color: Color.fromARGB(255, 145, 112, 23),
                                    )
                                  : const Text(''),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Keypad(
              addto: addToAmount,
            ),
          ],
        ),
      ),
    );
  }
}
