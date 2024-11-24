import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(CurrencyConverterApp());

class CurrencyConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CurrencyConverterPage(),
    );
  }
}

class CurrencyConverterPage extends StatefulWidget {
  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  // 汇率
  double? exchangeRateUSD; // 港币 -> 美元
  double? exchangeRateCNY; // 港币 -> 在岸人民币
  double? exchangeRateCNH; // 港币 -> 离岸人民币
  Map<String, double>? exchangeRates;
  double? selectedExchangeRate; // 港币 -> 当前选择的币种汇率
  String selectedCurrency = 'JPY'; // 默认选择日元

  // 输入框控制器
  TextEditingController hkdController = TextEditingController();
  TextEditingController usdController = TextEditingController();
  TextEditingController cnyController = TextEditingController();
  TextEditingController cnhController = TextEditingController();
  TextEditingController selectedCurrencyController = TextEditingController();

  String errorMessage = '';

  // 获取实时汇率
  // Future<void> getExchangeRates() async {
  //   final url = Uri.parse('https://openexchangerates.org/api/latest.json?app_id=3b0d31554f2946f7a5bac65d8cdee1c2');
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       setState(() {
  //         exchangeRates = Map<String, double>.from(data['rates']);
  //         exchangeRateUSD = data['rates']['USD'];
  //         exchangeRateCNY = data['rates']['CNY'];
  //         exchangeRateCNH = data['rates']['CNH'] ?? exchangeRateCNY; // 如果没有 CNH，则使用默认值
  //         selectedExchangeRate = data['rates'][selectedCurrency];
  //         errorMessage = ''; // 清空错误信息
  //       });
  //     } else {
  //       throw Exception('Failed to load exchange rates');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       errorMessage = '无法连接到汇率服务，请稍后重试。';
  //     });
  //   }
  // }

//   Future<void> getExchangeRates() async {
//   final url = Uri.parse(
//       'https://openexchangerates.org/api/latest.json?app_id=3b0d31554f2946f7a5bac65d8cdee1c2');
//   try {
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final rates = Map<String, double>.from(data['rates']);

//       // Base rate for HKD (used to recalculate other rates relative to HKD)
//       final hkdToUsd = 1 / rates['HKD']!;

//       setState(() {
//         exchangeRates = rates.map((currency, rate) => MapEntry(
//             currency, rate * hkdToUsd)); // Convert all rates to HKD-based
//         exchangeRateUSD = exchangeRates!['USD']; // HKD -> USD
//         exchangeRateCNY = exchangeRates!['CNY']; // HKD -> CNY
//         exchangeRateCNH =
//             exchangeRates!['CNH'] ?? exchangeRateCNY; // HKD -> CNH (fallback)
//         selectedExchangeRate =
//             exchangeRates![selectedCurrency]; // HKD -> selected currency
//         errorMessage = ''; // Clear errors
//       });
//     } else {
//       throw Exception('Failed to load exchange rates');
//     }
//   } catch (e) {
//     setState(() {
//       errorMessage = '无法连接到汇率服务，请稍后重试。';
//     });
//   }
// }


// Future<void> getExchangeRates() async {
//   final url = Uri.parse(
//       'https://openexchangerates.org/api/latest.json?app_id=3b0d31554f2946f7a5bac65d8cdee1c2');
//   try {
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final rates = Map<String, double>.from(data['rates']);

//       // Base rate for HKD (used to recalculate other rates relative to HKD)
//       final hkdToUsd = 1 / rates['HKD']!;

//       setState(() {
//         exchangeRates = rates.map((currency, rate) => MapEntry(
//             currency, rate * hkdToUsd)); // Convert all rates to HKD-based
//         exchangeRateUSD = exchangeRates!['USD']; // HKD -> USD
//         exchangeRateCNY = exchangeRates!['CNY']; // HKD -> CNY
//         exchangeRateCNH =
//             exchangeRates!['CNH'] ?? exchangeRateCNY; // HKD -> CNH (fallback)
//         selectedExchangeRate =
//             exchangeRates![selectedCurrency]; // HKD -> selected currency
//         errorMessage = ''; // Clear errors
//       });
//     } else {
//       setState(() {
//         errorMessage = '获取汇率失败。状态码：${response.statusCode}，错误原因：${response.reasonPhrase ?? "未知"}';
//       });
//     }
//   } catch (e) {
//     setState(() {
//       errorMessage = '无法连接到汇率服务，请检查网络连接或稍后重试。\n详细错误：$e';
//     });
//   }
// }

Future<void> getExchangeRates() async {
  final url = Uri.parse(
      'https://openexchangerates.org/api/latest.json?app_id=3b0d31554f2946f7a5bac65d8cdee1c2');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rawRates = Map<String, dynamic>.from(data['rates']);

      // Convert all rates to double, handling any potential int values
      final rates = rawRates.map((key, value) =>
          MapEntry(key, (value is int ? value.toDouble() : value)));

      // Base rate for HKD (used to recalculate other rates relative to HKD)
      final hkdToUsd = 1 / rates['HKD']!;

      setState(() {
        exchangeRates = rates.map((currency, rate) =>
            MapEntry(currency, rate * hkdToUsd)); // Convert all rates to HKD-based
        exchangeRateUSD = exchangeRates!['USD']; // HKD -> USD
        exchangeRateCNY = exchangeRates!['CNY']; // HKD -> CNY
        exchangeRateCNH =
            exchangeRates!['CNH'] ?? exchangeRateCNY; // HKD -> CNH (fallback)
        selectedExchangeRate =
            exchangeRates![selectedCurrency]; // HKD -> selected currency
        errorMessage = ''; // Clear errors
      });
    } else {
      setState(() {
        errorMessage =
            '获取汇率失败。状态码：${response.statusCode}，错误原因：${response.reasonPhrase ?? "未知"}';
      });
    }
  } catch (e) {
    setState(() {
      errorMessage = '无法连接到汇率服务，请检查网络连接或稍后重试。\n详细错误：$e';
    });
  }
}



  // 转换逻辑
  void _onHKDChanged(String value) {
    if (value.isEmpty || exchangeRateUSD == null) {
      usdController.clear();
      cnyController.clear();
      cnhController.clear();
      selectedCurrencyController.clear();
      return;
    }
    final hkd = double.tryParse(value);
    if (hkd != null) {
      usdController.text = (hkd * exchangeRateUSD!).toStringAsFixed(4);
      cnyController.text = (hkd * exchangeRateCNY!).toStringAsFixed(4);
      cnhController.text = (hkd * exchangeRateCNH!).toStringAsFixed(4);
      selectedCurrencyController.text = (hkd * selectedExchangeRate!).toStringAsFixed(4);
    }
  }

  void _onUSDChanged(String value) {
    if (value.isEmpty || exchangeRateUSD == null) {
      hkdController.clear();
      return;
    }
    final usd = double.tryParse(value);
    if (usd != null) {
      final hkd = usd / exchangeRateUSD!;
      hkdController.text = hkd.toStringAsFixed(4);
      cnyController.text = (hkd * exchangeRateCNY!).toStringAsFixed(4);
      cnhController.text = (hkd * exchangeRateCNH!).toStringAsFixed(4);
      selectedCurrencyController.text = (hkd * selectedExchangeRate!).toStringAsFixed(4);
    }
  }

  void _onCNYChanged(String value) {
    if (value.isEmpty || exchangeRateCNY == null) {
      hkdController.clear();
      return;
    }
    final cny = double.tryParse(value);
    if (cny != null) {
      final hkd = cny / exchangeRateCNY!;
      hkdController.text = hkd.toStringAsFixed(4);
      usdController.text = (hkd * exchangeRateUSD!).toStringAsFixed(4);
      cnhController.text = (hkd * exchangeRateCNH!).toStringAsFixed(4);
      selectedCurrencyController.text = (hkd * selectedExchangeRate!).toStringAsFixed(4);
    }
  }

  void _onCNHChanged(String value) {
    if (value.isEmpty || exchangeRateCNH == null) {
      hkdController.clear();
      return;
    }
    final cnh = double.tryParse(value);
    if (cnh != null) {
      final hkd = cnh / exchangeRateCNH!;
      hkdController.text = hkd.toStringAsFixed(4);
      usdController.text = (hkd * exchangeRateUSD!).toStringAsFixed(4);
      cnyController.text = (hkd * exchangeRateCNY!).toStringAsFixed(4);
      selectedCurrencyController.text = (hkd * selectedExchangeRate!).toStringAsFixed(4);
    }
  }

  void _onSelectedCurrencyChanged(String value) {
    if (value.isEmpty || selectedExchangeRate == null) {
      hkdController.clear();
      return;
    }
    final otherCurrency = double.tryParse(value);
    if (otherCurrency != null) {
      final hkd = otherCurrency / selectedExchangeRate!;
      hkdController.text = hkd.toStringAsFixed(4);
      usdController.text = (hkd * exchangeRateUSD!).toStringAsFixed(4);
      cnyController.text = (hkd * exchangeRateCNY!).toStringAsFixed(4);
      cnhController.text = (hkd * exchangeRateCNH!).toStringAsFixed(4);
    }
  }

  void _onCurrencyDropdownChanged(String? newCurrency) {
    if (newCurrency != null && exchangeRates != null) {
      setState(() {
        selectedCurrency = newCurrency;
        selectedExchangeRate = exchangeRates![newCurrency];
        // 清空已输入的内容
        hkdController.clear();
        selectedCurrencyController.clear();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getExchangeRates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('港币 <-> 美元/人民币 转换'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: errorMessage.isNotEmpty
            ? Center(
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: hkdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '港币 (HKD)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onHKDChanged,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: usdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '美元 (USD)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onUSDChanged,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: cnyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '在岸人民币 (CNY)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onCNYChanged,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: cnhController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '离岸人民币 (CNH)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onCNHChanged,
                  ),

                  SizedBox(height: 16),
                  // DropdownButtonFormField<String>(
                  //       value: selectedCurrency,
                  //       items: exchangeRates!.keys.map((currency) {
                  //         return DropdownMenuItem<String>(
                  //           value: currency,
                  //           child: Text(currency),
                  //         );
                  //       }).toList(),
                  //       onChanged: _onCurrencyDropdownChanged,
                  //       decoration: InputDecoration(
                  //         labelText: '选择币种',
                  //         border: OutlineInputBorder(),
                  //       ),
                  //     ),

                  DropdownButtonFormField<String>(
                    value: exchangeRates == null ? null : selectedCurrency,
                    items: exchangeRates == null
                        ? []
                        : exchangeRates!.keys.map((currency) {
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                    onChanged: exchangeRates == null ? null : _onCurrencyDropdownChanged,
                    decoration: InputDecoration(
                      labelText: '选择币种',
                      border: OutlineInputBorder(),
                    ),
                  ),




                      SizedBox(height: 16),
                      TextField(
                        controller: selectedCurrencyController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '$selectedCurrency',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _onSelectedCurrencyChanged,
                      ),




                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      hkdController.clear();
                      usdController.clear();
                      cnyController.clear();
                      cnhController.clear();
                      selectedCurrencyController.clear();
                    },
                    child: Text('Clear'),
                  ),
                ],
              ),
      ),
    );
  }
}
