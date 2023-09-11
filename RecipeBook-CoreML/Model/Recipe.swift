//
//  Recipe.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import Foundation

// swiftlint:disable identifier_name

struct Recipes: Codable {
    let recipes: [Recipe]
}

struct Recipe: Codable {
    let vegetarian, vegan, glutenFree, dairyFree: Bool
    let veryHealthy, cheap, veryPopular, sustainable: Bool
    let lowFodmap: Bool
    let weightWatcherSmartPoints: Int
    let gaps: Gaps
    let preparationMinutes, cookingMinutes, aggregateLikes, healthScore: Int
    let creditsText: CreditsText
    let license: License?
    let sourceName: SourceName
    let pricePerServing: Double
    let extendedIngredients: [ExtendedIngredient]
    let id: Int
    let title: String
    let readyInMinutes, servings: Int
    let sourceURL: String
    let image: String?
    let imageType: ImageType?
    let summary: String
    let cuisines, dishTypes: [String]
    let diets: [Diet]
    let occasions: [String]
    let instructions: String
    let analyzedInstructions: [AnalyzedInstruction]
    let spoonacularSourceURL: String

    enum CodingKeys: String, CodingKey {
        case vegetarian, vegan, glutenFree, dairyFree, veryHealthy, cheap, veryPopular, sustainable, lowFodmap
        case weightWatcherSmartPoints, gaps, preparationMinutes, cookingMinutes, aggregateLikes, healthScore
        case creditsText, license, sourceName, pricePerServing, extendedIngredients, id, title, readyInMinutes, servings
        case sourceURL = "sourceUrl"
        case image, imageType, summary, cuisines, dishTypes, diets, occasions, instructions, analyzedInstructions
        case spoonacularSourceURL = "spoonacularSourceUrl"
    }
}

struct AnalyzedInstruction: Codable {
    let name: Name
    let steps: [Step]
}

enum Name: String, Codable {
    case empty = ""
    case forTheCrepes = "FOR THE CREPES"
    case prepareTheRub = "Prepare the rub"
}

struct Step: Codable {
    let number: Int
    let step: String
    let ingredients, equipment: [Ent]
    let length: Length?
}

struct Ent: Codable {
    let id: Int
    let name, localizedName, image: String
    let temperature: Length?
}

struct Length: Codable {
    let number: Int
    let unit: Unit
}

enum Unit: String, Codable {
    case celsius = "Celsius"
    case fahrenheit = "Fahrenheit"
    case minutes
}

enum CreditsText: String, Codable {
    case foodistaCOM = "foodista.com"
    case foodistaCOMTheCookingEncyclopediaEveryoneCanEdit = "Foodista.com – The Cooking Encyclopedia Everyone Can Edit"
    case fullBellySisters = "Full Belly Sisters"
    case jenWest = "Jen West"
    case pinkwhenCOM = "pinkwhen.com"
}

enum Diet: String, Codable {
    case dairyFree = "dairy free"
    case fodmapFriendly = "fodmap friendly"
    case glutenFree = "gluten free"
    case ketogenic
    case lactoOvoVegetarian = "lacto ovo vegetarian"
    case paleolithic
    case pescatarian
    case primal
    case vegan
    case whole30 = "whole 30"
}

struct ExtendedIngredient: Codable {
    let id: Int
    let aisle: Aisle?
    let image: String?
    let consistency: Consistency
    let name: String
    let nameClean: String?
    let original, originalName: String
    let amount: Double
    let unit: String
    let meta: [String]
    let measures: Measures
}

enum Aisle: String, Codable {
    case alcoholicBeverages = "Alcoholic Beverages"
    case bakeryBread = "Bakery/Bread"
    case baking = "Baking"
    case beverages = "Beverages"
    case cannedAndJarred = "Canned and Jarred"
    case cereal = "Cereal"
    case cheese = "Cheese"
    case condiments = "Condiments"
    case driedFruits = "Dried Fruits"
    case empty = "?"
    case ethnicFoods = "Ethnic Foods"
    case frozen = "Frozen"
    case glutenFree = "Gluten Free"
    case gourmet = "Gourmet"
    case healthFoods = "Health Foods"
    case meat = "Meat"
    case milkEggsOtherDairy = "Milk, Eggs, Other Dairy"
    case nutButtersJamsAndHoney = "Nut butters, Jams, and Honey"
    case nuts = "Nuts"
    case oilVinegarSaladDressing = "Oil, Vinegar, Salad Dressing"
    case pastaAndRice = "Pasta and Rice"
    case produce = "Produce"
    case refrigerated = "Refrigerated"
    case savorySnacks = "Savory Snacks"
    case seafood = "Seafood"
    case spicesAndSeasonings = "Spices and Seasonings"
    case sweetSnacks = "Sweet Snacks"
}

enum Consistency: String, Codable {
    case liquid = "LIQUID"
    case solid = "SOLID"
}

// MARK: - Measures

struct Measures: Codable {
    let us, metric: Metric
}

// MARK: - Metric

struct Metric: Codable {
    let amount: Double
    let unitShort, unitLong: String
}

enum Gaps: String, Codable {
    case gaps4 = "GAPS_4"
    case gapsFull = "GAPS_FULL"
    case no
}

enum ImageType: String, Codable {
    case jpg
    case png
}

enum License: String, Codable {
    case ccBy30 = "CC BY 3.0"
    case ccBySa30 = "CC BY-SA 3.0"
}

enum SourceName: String, Codable {
    case foodista = "Foodista"
    case foodistaCOM = "foodista.com"
    case fullBellySisters = "Full Belly Sisters"
    case pinkWhen = "Pink When"
    case pinkwhenCOM = "pinkwhen.com"
}

// swiftlint:enable identifier_name
