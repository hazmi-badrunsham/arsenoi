import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map recipeData;

  @override
  void initState() {
    super.initState();
    _fetchRecipe();
  }

  Future<void> _fetchRecipe() async {
    final response = await http.get(Uri.parse('http://localhost:3000/recipes/nasi-goreng'));

    if (response.statusCode == 200) {
      setState(() {
        recipeData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load recipe');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (recipeData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Recipe App')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Book'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(recipeData['image_url']),
            SizedBox(height: 16),
            Text(
              recipeData['title'],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 16),
                SizedBox(width: 4),
                Text("${recipeData['time']} min"),
                SizedBox(width: 16),
                Icon(Icons.star, size: 16, color: Colors.amber),
                SizedBox(width: 4),
                Text("${recipeData['rating']}"),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  RecipeDetailsScreen.routeName,
                  arguments: recipeData,
                );
              },
              child: Text('View Recipe Details'),
            ),
          ],
        ),
      ),
    );
  }
}
