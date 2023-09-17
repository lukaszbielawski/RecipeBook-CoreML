//
//  Recipe.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import Foundation

// swiftlint:disable identifier_name

struct RandomRecipes: Decodable, RecipeContainer {
    var recipes: [Recipe]
    func getRecipes() -> [Recipe] { return recipes }
}

struct SearchRecipes: Decodable, RecipeContainer {
    var results: [Recipe]
    var offset, number, totalResults: Int?

    func getRecipes() -> [Recipe] { return results }
}

struct Recipe: Codable {
    let vegetarian, vegan, glutenFree, dairyFree: Bool
    let veryHealthy, cheap, veryPopular, sustainable: Bool?
    let lowFodmap: Bool?
    let weightWatcherSmartPoints: Int?
    let preparationMinutes, cookingMinutes, aggregateLikes: Int?
    let healthScore: Int
    let pricePerServing: Double?
    let id: Int?
    let title: String?
    let readyInMinutes, servings: Int
    let sourceURL: String?
    let image: String?
    let summary: String?
    let cuisines, dishTypes: [String]?
    let occasions: [String]?
    let instructions: String?
    let analyzedInstructions: [AnalyzedInstruction]
    let spoonacularSourceURL: String?

    enum CodingKeys: String, CodingKey {
        case vegetarian, vegan, glutenFree, dairyFree, veryHealthy, cheap
        case veryPopular, sustainable, lowFodmap, weightWatcherSmartPoints
        case preparationMinutes, cookingMinutes, aggregateLikes, healthScore
        case pricePerServing, id, title, readyInMinutes, servings
        case sourceURL = "sourceUrl"
        case image, summary, cuisines, dishTypes, occasions, instructions, analyzedInstructions
        case spoonacularSourceURL = "spoonacularSourceUrl"
    }
}

struct AnalyzedInstruction: Codable {
//    let name: Name?
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
    let id: Int?
    let name: String
    let localizedName: String?
    let image: String
    let temperature: Length?
}

struct Length: Codable {
    let number: Int?
    let unit: Unit?
}

enum Unit: String, Codable {
    case celsius = "Celsius"
    case fahrenheit = "Fahrenheit"
    case minutes
}

struct Measures: Codable {
    let us, metric: Metric?
}

struct Metric: Codable {
    let amount: Double?
    let unitShort, unitLong: String?
}

// swiftlint:enable identifier_name
