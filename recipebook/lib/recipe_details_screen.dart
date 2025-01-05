import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatelessWidget {
  static const routeName = '/recipe-details';

  @override
  Widget build(BuildContext context) {
    final recipe = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title']),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe['image_url']),
            SizedBox(height: 16),
            Text(
              recipe['title'],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 16),
                SizedBox(width: 4),
                Text("${recipe['time']} min"),
                SizedBox(width: 16),
                Icon(Icons.star, size: 16, color: Colors.amber),
                SizedBox(width: 4),
                Text("${recipe['rating']}"),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Ingredients",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...recipe['ingredients'].map<Widget>((ingredient) {
              return ListTile(
                leading: Icon(Icons.check, color: Colors.green),
                title: Text(ingredient),
              );
            }).toList(),
            SizedBox(height: 16),
            Text(
              "Steps",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...recipe['steps'].map<Widget>((step) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text("${recipe['steps'].indexOf(step) + 1}"),
                ),
                title: Text(step),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
