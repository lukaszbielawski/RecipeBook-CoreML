//
//  Enum.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 17/09/2023.
//

import Foundation

enum NetworkRecipesRequestType {
    static let apiKey = "e8194bc2f7764d37ac898cbb402e4f4d"
    static let number = 100

    case searchRecipes
    case randomRecipes

    //    "https://api.spoonacular.com/recipes/complexSearch"
    //    "https://api.spoonacular.com/recipes/random"

    var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.spoonacular.com"
        components.queryItems = [
            URLQueryItem(name: "apiKey", value: Self.apiKey),
            URLQueryItem(name: "number", value: String(Self.number))
        ]

        switch self {
        case .searchRecipes:
            components.path = "/recipes/complexSearch"
            components.queryItems?.append(URLQueryItem(name: "addRecipeInformation", value: "true"))
        case .randomRecipes:
            components.path = "/recipes/random"
        }

        return components
    }

    var parseType: RecipeContainer.Type {
        switch self {
        case .randomRecipes:
            return RandomRecipes.self
        case .searchRecipes:
            return SearchRecipes.self
        }
    }
}
