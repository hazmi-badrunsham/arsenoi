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
    PlaceholderPage(title: "Latest News"),
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
        selectedItemColor: Colors.black, // Selected item color (black)
        unselectedItemColor: Colors.black, // Unselected item color (black)
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
            icon: Icon(Icons.newspaper),
            label: "News",
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

// New Trending Stock Page
class TrendingStockPage extends StatefulWidget {
  @override
  _TrendingStockPageState createState() => _TrendingStockPageState();
}

class _TrendingStockPageState extends State<TrendingStockPage> {
  List<Map<String, dynamic>> _topGainers = [];
  bool _isLoading = true;

  Future<void> fetchTopGainers() async {
    final apiKey = 'cttppk1r01qqhvb16ptgcttppk1r01qqhvb16pu0'; // Replace with your Finnhub API key
    final symbolUrl =
        'https://finnhub.io/api/v1/stock/symbol?exchange=US&token=$apiKey';

    try {
      final symbolResponse = await http.get(Uri.parse(symbolUrl));
      if (symbolResponse.statusCode == 200) {
        final List<dynamic> symbols = json.decode(symbolResponse.body);
        final List<Map<String, dynamic>> stockData = [];

        // Fetch stock quotes for the first 20 symbols (to avoid API limits)
        for (int i = 0; i < 20; i++) {
          final symbol = symbols[i]['symbol'];
          final quoteUrl =
              'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey';
          final quoteResponse = await http.get(Uri.parse(quoteUrl));

          if (quoteResponse.statusCode == 200) {
            final quote = json.decode(quoteResponse.body);
            stockData.add({
              'symbol': symbol,
              'currentPrice': quote['c'],
              'previousClose': quote['pc'],
              'percentChange':
                  ((quote['c'] - quote['pc']) / quote['pc']) * 100,
            });
          }
        }

        // Sort stocks by percentage change in descending order
        stockData.sort((a, b) =>
            b['percentChange'].compareTo(a['percentChange']));

        setState(() {
          _topGainers = stockData.take(10).toList(); // Top 10 gainers
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch stock symbols.');
      }
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
        title: Text('Top Gainers'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _topGainers.length,
              itemBuilder: (context, index) {
                final stock = _topGainers[index];
                return ListTile(
                  title: Text(stock['symbol']),
                  subtitle: Text(
                      'Change: ${stock['percentChange'].toStringAsFixed(2)}%'),
                  trailing: Text(
                    '\$${stock['currentPrice'].toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
    );
  }
}



// Placeholder pages for other navigation items
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
