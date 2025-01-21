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
    PlaceholderPage(title: "Community Suggestions"),
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
    'AAPL', // Apple
    'MSFT', // Microsoft
    'GOOGL', // Alphabet (Google)
    'AMZN', // Amazon
    'TSLA', // Tesla
    'META', // Meta (Facebook)
    'NVDA', // NVIDIA
    'NFLX', // Netflix
    'AMD',  // AMD
    'INTC', // Intel
  ];

  // Fetch stock data from Finnhub
  Future<void> fetchTopGainers() async {
    try {
      List<Map<String, dynamic>> stockData = [];

      for (String symbol in predefinedSymbols) {
        final quoteUrl =
            'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey';
        final response = await http.get(Uri.parse(quoteUrl));

        if (response.statusCode == 200) {
          final quote = json.decode(response.body);

          final double open = quote['o'] ?? 0.0; // Open price
          final double close = quote['c'] ?? 0.0; // Current/Close price
          final double change = ((close - open) / (open == 0.0 ? 1 : open)) *
              100; // Percent change

          stockData.add({
            'symbol': symbol,
            'open': open,
            'close': close,
            'percentChange': change,
          });
        }
      }

      // Sort by percent change in descending order
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
  bool _isLoading = true;
  Map<String, dynamic> _signalData = {};
  final String apiKey = 'ZUAUI6SONHCTRLKQ'; // Replace with your API key

  @override
  void initState() {
    super.initState();
    fetchStockSignals('AAPL'); // Default stock for signals
  }

  Future<void> fetchStockSignals(String symbol) async {
    setState(() {
      _isLoading = true;
      _signalData = {}; // Reset signal data
    });

    final url =
        'https://www.alphavantage.co/query?function=RSI&symbol=$symbol&interval=daily&time_period=14&series_type=close&apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['Technical Analysis: RSI'] != null) {
          final rsiData = data['Technical Analysis: RSI'];
          final latestDate = rsiData.keys.first;
          final latestRSI = double.parse(rsiData[latestDate]['RSI']);
          String signal = '';

          if (latestRSI < 30) {
            signal = 'Buy Signal (Oversold)';
          } else if (latestRSI > 70) {
            signal = 'Sell Signal (Overbought)';
          } else {
            signal = 'Hold';
          }

          setState(() {
            _signalData = {
              'symbol': symbol,
              'date': latestDate,
              'rsi': latestRSI,
              'signal': signal,
            };
            _isLoading = false;
          });
        } else {
          setState(() {
            _signalData = {'error': 'No signals found for $symbol'};
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _signalData = {
            'error': 'Failed to fetch signals. Status Code: ${response.statusCode}'
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _signalData = {'error': 'Network error: $e'};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Stock Signals'),
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
                  fetchStockSignals(value.toUpperCase());
                }
              },
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _signalData.containsKey('error')
                    ? Center(
                        child: Text(
                          _signalData['error'],
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stock Symbol: ${_signalData['symbol'] ?? 'N/A'}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Date: ${_signalData['date'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'RSI: ${_signalData['rsi']?.toStringAsFixed(2) ?? 'N/A'}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Signal: ${_signalData['signal'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _signalData['signal'] == 'Buy Signal (Oversold)'
                                    ? Colors.green
                                    : _signalData['signal'] ==
                                            'Sell Signal (Overbought)'
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
