import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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

class TrendingStockPage extends StatefulWidget {
  @override
  _TrendingStockPageState createState() => _TrendingStockPageState();
}

class _TrendingStockPageState extends State<TrendingStockPage> {
  List<Map<String, dynamic>> _topGainers = [];
  bool _isLoading = true;

  // Replace with your Alpha Vantage API key
  final String apiKey = 'ZUAUI6SONHCTRLKQ';
  final String symbol = 'IBM';  // Set this to any stock symbol you want to fetch

  Future<void> fetchTopGainers() async {
    final String url =
        'https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey("Time Series (Daily)")) {
          final dailyData = data["Time Series (Daily)"] as Map<String, dynamic>;
          final List<Map<String, dynamic>> stockData = [];

          dailyData.forEach((date, values) {
            final open = double.tryParse(values['1. open']) ?? 0.0;
            final close = double.tryParse(values['4. close']) ?? 0.0;
            final change = ((close - open) / open) * 100;

            stockData.add({
              'date': date,
              'open': open,
              'close': close,
              'percentChange': change,
              'name': symbol, // Dynamically show stock symbol
            });
          });

          stockData.sort((a, b) =>
              b['percentChange'].compareTo(a['percentChange']));

          setState(() {
            _topGainers = stockData.take(10).toList();
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid data format returned by Alpha Vantage.');
        }
      } else {
        throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
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
                  title: Text('${stock['name']} (${stock['date']})'),
                  subtitle: Text(
                      'Change: ${stock['percentChange'].toStringAsFixed(2)}%'),
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

class TrendingNewsPage extends StatefulWidget {
  @override
  _TrendingNewsPageState createState() => _TrendingNewsPageState();
}

class _TrendingNewsPageState extends State<TrendingNewsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _articles = [];

  // Replace with your NewsAPI key
  final String apiKey = '507446fca10d45b4ad2f94bbf5f8cb97';

  // Fetch stock-related news
  Future<void> fetchTrendingNews() async {
    final url =
        'https://newsapi.org/v2/everything?q=stock&language=en&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if status is ok and if articles are present
        if (data['status'] == 'ok' && data['articles'] != null) {
          final List articles = data['articles'];
          setState(() {
            _articles = articles.map((article) {
              return {
                'title': article['title'],
                'description': article['description'],
                'url': article['url'],
                'publishedAt': article['publishedAt'],
              };
            }).toList();
            _isLoading = false;
          });
        } else {
          // If no articles are returned
          setState(() {
            _isLoading = false;
            _articles = [];
          });
          print('No articles found or invalid response structure.');
        }
      } else {
        throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _articles = [];
      });
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTrendingNews(); // Fetch news when the page is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trending News - US Stocks'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _articles.isEmpty
              ? Center(child: Text('No trending news found.'))
              : ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    final article = _articles[index];
                    return ListTile(
                      title: Text(article['title']),
                      subtitle: Text(article['description'] ?? 'No description available'),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        // Open the full article in a web browser
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsDetailPage(url: article['url']),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final String url;

  NewsDetailPage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Detail'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Open the URL in a web browser using `url_launcher`
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
          child: Text('Open Article in Browser'),
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
