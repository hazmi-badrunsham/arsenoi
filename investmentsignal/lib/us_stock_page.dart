import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'US Stock Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: USStockPage(),
    );
  }
}

class USStockPage extends StatefulWidget {
  @override
  _USStockPageState createState() => _USStockPageState();
}

class _USStockPageState extends State<USStockPage> {
  int _currentIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = [
    USStockPageContent(),
    TrendingStockPage(),
    CommunitySuggestionsPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: "Stocks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: "Trending",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Community",
          ),
        ],
      ),
    );
  }
}

class USStockPageContent extends StatefulWidget {
  @override
  _USStockPageContentState createState() => _USStockPageContentState();
}

class _USStockPageContentState extends State<USStockPageContent> {
  final TextEditingController _controller = TextEditingController();
  String _stockSymbol = 'AAPL'; // Default stock symbol (Apple)
  Map<String, dynamic> _stockData = {};
  bool _isLoading = false;

  Future<void> fetchStockData() async {
    setState(() {
      _isLoading = true;
    });

    final apiKey = 'cttppk1r01qqhvb16ptgcttppk1r01qqhvb16pu0'; // Replace with your Finnhub API key
    final url =
        'https://finnhub.io/api/v1/quote?symbol=$_stockSymbol&token=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _stockData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _stockData = {
            'error': 'Failed to fetch data. Status Code: ${response.statusCode}'
          };
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _stockData = {'error': 'Network error: $e'};
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStockData(); // Fetch default stock data
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter Stock Symbol (e.g., AAPL, TSLA)',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              setState(() {
                _stockSymbol = value.toUpperCase(); // Ensure symbol is uppercase
              });
              fetchStockData();
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _stockSymbol = _controller.text.toUpperCase();
              });
              fetchStockData();
            },
            child: Text('Fetch Stock Data'),
          ),
          SizedBox(height: 20),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _stockData.containsKey('error')
                  ? Center(child: Text(_stockData['error']))
                  : Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stock Symbol: $_stockSymbol',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Current Price: \$${_stockData['c'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'High Price: \$${_stockData['h'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Low Price: \$${_stockData['l'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Previous Close: \$${_stockData['pc'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}

class TrendingStockPage extends StatefulWidget {
  @override
  _TrendingStockPageState createState() => _TrendingStockPageState();
}

class _TrendingStockPageState extends State<TrendingStockPage> {
  List<Map<String, dynamic>> _topGainers = [];
  bool _isLoading = true;

  // Replace with your Finnhub API key
  final String apiKey = 'cttppk1r01qqhvb16ptgcttppk1r01qqhvb16pu0';

  // Predefined list of stock symbols
  final List<String> predefinedSymbols = [
    'AAPL',
    'MSFT',
    'GOOGL',
    'AMZN',
    'TSLA',
    'META',
    'NVDA',
    'NFLX',
    'AMD',
    'INTC',
  ];

  Future<void> fetchTopGainers() async {
    try {
      List<Map<String, dynamic>> stockData = [];

      for (String symbol in predefinedSymbols) {
        final quoteUrl =
            'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey';
        final response = await http.get(Uri.parse(quoteUrl));

        if (response.statusCode == 200) {
          final quote = json.decode(response.body);

          final double open = quote['o'] ?? 0.0;
          final double close = quote['c'] ?? 0.0;
          final double change = ((close - open) / (open == 0.0 ? 1 : open)) *
              100;

          stockData.add({
            'symbol': symbol,
            'open': open,
            'close': close,
            'percentChange': change,
          });
        }
      }

      stockData.sort((a, b) =>
          b['percentChange'].compareTo(a['percentChange']));

      setState(() {
        _topGainers = stockData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTopGainers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Stock - US Stocks'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _topGainers.isEmpty
              ? Center(child: Text('No top gainers found.'))
              : ListView.builder(
                  itemCount: _topGainers.length,
                  itemBuilder: (context, index) {
                    final stock = _topGainers[index];
                    return ListTile(
                      title: Text(stock['symbol']),
                      subtitle: Text(
                        'Change: ${stock['percentChange'].toStringAsFixed(2)}%',
                      ),
                      trailing: Text(
                        'Close: \$${stock['close'].toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
    );
  }
}






class CommunitySuggestionsPage extends StatefulWidget {
  @override
  _CommunitySuggestionsPageState createState() =>
      _CommunitySuggestionsPageState();
}

class _CommunitySuggestionsPageState extends State<CommunitySuggestionsPage> {
  bool _isLoading = false;
  Map<String, dynamic> _stockData = {};
  final String apiKey = 'o3X9tFDaOBCnusYGQbvLR6mHTBjkG1YQ'; // Replace with your Polygon API Key

  Future<void> fetchStockData(String symbol) async {
    setState(() {
      _isLoading = true;
      _stockData = {};
    });

    try {
      final url =
          'https://api.polygon.io/v2/aggs/ticker/$symbol/range/1/day/2023-01-01/2025-01-01?apiKey=$apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['results'] != null && data['results'].isNotEmpty) {
          final prices = data['results'].map((e) => e['c']).toList();
          final closePrices = prices.cast<double>();

          // Calculate indicators
          final rsi = calculateRSI(closePrices);
          final movingAverageShort = calculateMovingAverage(closePrices, 10);
          final movingAverageLong = calculateMovingAverage(closePrices, 50);
          final atr = calculateATR(data['results']);
          final signal = determineSignal(rsi, movingAverageShort, movingAverageLong);

          setState(() {
            _stockData = {
              'symbol': symbol,
              'rsi': rsi,
              'movingAverageShort': movingAverageShort,
              'movingAverageLong': movingAverageLong,
              'atr': atr,
              'signal': signal,
            };
            _isLoading = false;
          });
        } else {
          setState(() {
            _stockData = {'error': 'No data available for $symbol'};
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _stockData = {
            'error': 'Failed to fetch data. Status Code: ${response.statusCode}'
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _stockData = {'error': 'Network error: $e'};
        _isLoading = false;
      });
    }
  }

  double calculateRSI(List<double> prices) {
    if (prices.length < 14) return 0.0;

    double gain = 0.0, loss = 0.0;
    for (int i = 1; i <= 14; i++) {
      final diff = prices[i] - prices[i - 1];
      if (diff > 0) {
        gain += diff;
      } else {
        loss -= diff;
      }
    }

    final avgGain = gain / 14;
    final avgLoss = loss / 14;
    if (avgLoss == 0) return 100.0;

    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  double calculateMovingAverage(List<double> prices, int period) {
    if (prices.length < period) return 0.0;

    final sublist = prices.take(period).toList();
    return sublist.reduce((a, b) => a + b) / period;
  }

  double calculateATR(List<dynamic> data) {
    if (data.length < 14) return 0.0;

    double atr = 0.0;
    for (int i = 1; i < data.length; i++) {
      final highLow = data[i]['h'] - data[i]['l'];
      final highClose = (data[i]['h'] - data[i - 1]['c']).abs();
      final lowClose = (data[i]['l'] - data[i - 1]['c']).abs();

      atr += [highLow, highClose, lowClose].reduce((a, b) => a > b ? a : b);
    }

    return atr / 14;
  }

  String determineSignal(double rsi, double shortMA, double longMA) {
    if (rsi < 30 && shortMA > longMA) {
      return 'Buy';
    } else if (rsi > 70 && shortMA < longMA) {
      return 'Sell';
    } else {
      return 'Hold';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Suggestions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter Stock Symbol (e.g., AAPL, TSLA)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  fetchStockData(value.toUpperCase());
                }
              },
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _stockData.containsKey('error')
                    ? Center(
                        child: Text(
                          _stockData['error'],
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stock Symbol: ${_stockData['symbol'] ?? 'N/A'}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text('RSI: ${_stockData['rsi']?.toStringAsFixed(2) ?? 'N/A'}'),
                            Text(
                                'Short Moving Average: ${_stockData['movingAverageShort']?.toStringAsFixed(2) ?? 'N/A'}'),
                            Text(
                                'Long Moving Average: ${_stockData['movingAverageLong']?.toStringAsFixed(2) ?? 'N/A'}'),
                            Text('ATR: ${_stockData['atr']?.toStringAsFixed(2) ?? 'N/A'}'),
                            SizedBox(height: 10),
                            Text(
                              'Signal: ${_stockData['signal'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _stockData['signal'] == 'Buy'
                                    ? Colors.green
                                    : _stockData['signal'] == 'Sell'
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}



class PlaceholderPage extends StatelessWidget {
  final String title;

  PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

