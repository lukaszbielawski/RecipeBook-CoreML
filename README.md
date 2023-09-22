# RecipeBook-CoreML





The Recipe Book app, built with UIKit, Swift Concurrency, Combine and Vision frameworks, is your one-stop culinary companion. It offers a rich user experience for discovering, filtering, and exploring recipes, with the added bonus of ingredient recognition through machine learning. 

<h2>Features</h2>

* Recipe Display: Browse and view a collection of delicious recipes in a user-friendly UITableView.
* Detailed View: Dive deep into your chosen recipe to access a detailed view with ingredients and step-by-step instructions.
* Recipe Search: Effortlessly search for recipes by keywords, ingredients, or dish names.
* Filtering: Use the segmented control filters to refine your recipe search by ingredients, dish type, or dietary intolerances.
* Ingredient Recognition: Harness the power of machine learning with the Vision framework to identify ingredients through image classification.
* Recipe Constructor: Search recipes based on ingredients previously scanned with the app's ingredient recognition feature.
  
<h2>Presentation</h2>

https://github.com/lukaszbielawski/RecipeBook-CoreML/assets/44624897/d9b7a6fe-0cd4-4467-890f-2cda4589fc2f

<h2>Requirements</h2>

* Xcode 13.0+
* Swift 5.5+
* iOS 15.0+

<h2>Installation</h2>

1. Clone the repository:

```bash
git clone https://github.com/lukaszbielawski/RecipeBook-CoreML
```

2. Open the project in Xcode.
3. Build and run the app on a simulator or a physical device running iOS 15.0 or later.

<h2>Usage</h2>

<h3>Recipe Display</h3>

1. Launch the app on your iOS device.
2. Explore the list of recipes presented in the UITableView.
3. Scroll through the recipes, and tap on one to view its details.

<h3>Recipe Search</h3>

1. On the main screen, use the search bar at the top to search for recipes by keywords, ingredients, or dish names.
2. You may add additional filters or make use of the <i>Search</i> button localized next to search bar

<h3>Recipe Filtering</h3>

1. Click the chervon-shaped button to expand filter menu.
2. Use the segmented control filters below the search bar to filter recipes based on criteria like ingredients, dish type, or intolerances.
3. After clicking the <i>Search</i> button, recipes displayed will update according to your selected filter.

<h3>Detailed View</h3>

1. Tapping on a recipe in the UITableView will take you to a detailed view.
2. Here, you can find a list of ingredients for every step and step-by-step instructions to prepare the dish in a well-animated theme.

<h3>Ingredient Recognition and Recipe Constructor</h3>

1. Access the camera scan feature by tapping the camera icon or a dedicated button.
2. Point the camera at ingredients or items you'd like to identify and press button with camera icon.
3. The app's machine learning model, trained using Core ML, will recognize ingredients.
4. You may press tick button to passthrough scanned ingredients to the Spoonacular's API endpoint.
5. Recipes with the least missing ingredients will rank at the top of the retrieved list.
   
<h2>License</h2>

<a href="https://www.mit.edu/~amini/LICENSE.md">MIT License</a>
