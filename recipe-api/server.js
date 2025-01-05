const express = require('express');
const mongoose = require('mongoose');
const path = require('path');

// Initialize app
const app = express();

// Use Express's built-in JSON parser
app.use(express.json());

// Serve static files
app.use('/public', express.static(path.join(__dirname, 'public')));

// Connect to MongoDB with error handling
mongoose.connect('mongodb://localhost:27017/recipeDB', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('MongoDB connected successfully');
})
.catch(err => {
  console.error('MongoDB connection error:', err);
});

// Define Recipe Schema with validation
const recipeSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: String,
  ingredients: { type: [String], required: true },
  steps: { type: [String], required: true },
  image_url: String,
  category: String,
  time: { type: Number, min: 1 },
  rating: { type: Number, min: 0, max: 5 }
});

// Create Recipe Model
const Recipe = mongoose.model('Recipe', recipeSchema);

// Sample Recipe Data (Nasi Goreng)
const nasiGorengRecipe = new Recipe({
  title: "Nasi Goreng",
  description: "A popular Indonesian fried rice dish made with a mix of ingredients and savory seasonings.",
  ingredients: [
    "2 cups cooked rice",
    "2 tablespoons vegetable oil",
    "1 onion, finely chopped",
    "2 cloves garlic, minced",
    "1 red chili, chopped",
    "1 carrot, grated",
    "2 eggs, beaten",
    "2 tablespoons soy sauce",
    "1 tablespoon kecap manis (sweet soy sauce)",
    "Chicken or shrimp (optional)",
    "Cucumber slices (for garnish)",
    "Fried shallots (for garnish)"
  ],
  steps: [
    "Heat oil in a wok or large pan over medium heat.",
    "Add onion, garlic, and chili, sauté until softened.",
    "Add the grated carrot and cook for another 2 minutes.",
    "Push the ingredients to one side of the pan, then pour in the beaten eggs. Scramble until cooked.",
    "Add the rice, soy sauce, and kecap manis, and stir-fry until the rice is evenly coated and heated through.",
    "Add cooked chicken or shrimp if desired.",
    "Serve the Nasi Goreng with cucumber slices and garnish with fried shallots."
  ],
  image_url: "/public/images/nasi-goreng.jpg", // Updated to use the hosted image
  category: "Indonesian",
  time: 20,
  rating: 4.5
});

// Save the sample recipe to MongoDB
nasiGorengRecipe.save()
  .then(() => {
    console.log('Nasi Goreng recipe saved!');
  })
  .catch(err => {
    console.error('Error saving recipe:', err);
  });

// REST API Endpoints

// 1. Add a New Recipe
app.post('/recipes', async (req, res) => {
  try {
    const recipe = new Recipe(req.body);
    await recipe.save();
    res.status(201).send(recipe);  // Send success response
  } catch (err) {
    console.error('Error saving recipe:', err);
    res.status(500).send({ message: 'Failed to create recipe' });
  }
});

// 2. Get All Recipes
app.get('/recipes', async (req, res) => {
  try {
    const recipes = await Recipe.find();
    res.send(recipes);
  } catch (err) {
    console.error('Error fetching recipes:', err);
    res.status(500).send({ message: 'Failed to fetch recipes' });
  }
});

// 3. Get a Recipe by ID
app.get('/recipes/:id', async (req, res) => {
  try {
    const recipe = await Recipe.findById(req.params.id);
    if (recipe) {
      res.send(recipe);
    } else {
      res.status(404).send({ message: 'Recipe not found' });
    }
  } catch (err) {
    console.error('Error fetching recipe by ID:', err);
    res.status(500).send({ message: 'Failed to fetch recipe' });
  }
});

// 4. Update a Recipe
app.put('/recipes/:id', async (req, res) => {
  try {
    const recipe = await Recipe.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (recipe) {
      res.send(recipe);
    } else {
      res.status(404).send({ message: 'Recipe not found' });
    }
  } catch (err) {
    console.error('Error updating recipe:', err);
    res.status(500).send({ message: 'Failed to update recipe' });
  }
});

// 5. Delete a Recipe
app.delete('/recipes/:id', async (req, res) => {
  try {
    const recipe = await Recipe.findByIdAndDelete(req.params.id);
    if (recipe) {
      res.send({ message: 'Recipe deleted successfully' });
    } else {
      res.status(404).send({ message: 'Recipe not found' });
    }
  } catch (err) {
    console.error('Error deleting recipe:', err);
    res.status(500).send({ message: 'Failed to delete recipe' });
  }
});
// 6. Get Nasi Goreng Recipe by Title
app.get('/recipes/nasi-goreng', async (req, res) => {
    try {
      const recipe = await Recipe.findOne({ title: 'Nasi Goreng' });
      if (recipe) {
        res.send(recipe);
      } else {
        res.status(404).send({ message: 'Nasi Goreng recipe not found' });
      }
    } catch (err) {
      console.error('Error fetching Nasi Goreng recipe:', err);
      res.status(500).send({ message: 'Failed to fetch recipe' });
    }
  });
  
// Start Server
app.listen(3000, () => {
  console.log('Server is running on http://localhost:3000');
});
