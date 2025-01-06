import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MalaysiaStockPage extends StatefulWidget {
  @override
  _MalaysiaStockPageState createState() => _MalaysiaStockPageState();
}

class _MalaysiaStockPageState extends State<MalaysiaStockPage> {
  final TextEditingController _controller = TextEditingController();
  String _stockCode = '5183'; // Default stock code (e.g., Public Bank)
  Map<String, dynamic> _stockData = {};
  bool _isLoading = false;

  // Fetch stock data from KLSE StockQuote API
  Future<void> fetchStockData() async {
    setState(() {
      _isLoading = true;
    });

    final url = 'https://klse-api.vercel.app/api/v1/stock/$_stockCode';

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
            'error': 'Failed to load data (Status: ${response.statusCode})'
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
    fetchStockData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Malaysia Stock Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Stock Code (e.g., 5183 for Public Bank)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                setState(() {
                  _stockCode = value;
                });
                fetchStockData();
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _stockCode = _controller.text;
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
                                'Stock Name: ${_stockData['name'] ?? 'N/A'}',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Last Price: RM ${_stockData['last_price'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'High: RM ${_stockData['high'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Low: RM ${_stockData['low'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Volume: ${_stockData['volume'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
