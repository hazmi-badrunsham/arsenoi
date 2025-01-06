import 'package:flutter/material.dart';
import 'us_stock_page.dart'; // Import US stock page
import 'malaysia_stock_page.dart'; // Import Malaysia stock page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        '/usStock': (context) => USStockPage(),
        '/malaysiaStock': (context) => MalaysiaStockPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/usStock');
              },
              child: Text('US Stock Tracker'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/malaysiaStock');
              },
              child: Text('Malaysia Stock Tracker'),
            ),
          ],
        ),
      ),
    );
  }
}
