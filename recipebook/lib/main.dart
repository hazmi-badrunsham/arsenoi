import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'recipe_details_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomeScreen(),
      routes: {
        RecipeDetailsScreen.routeName: (context) => RecipeDetailsScreen(),
      },
    );
  }
}
