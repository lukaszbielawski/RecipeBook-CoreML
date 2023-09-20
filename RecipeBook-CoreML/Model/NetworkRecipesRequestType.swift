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
    case scannerRecipes

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
            components.queryItems?.append(URLQueryItem(name: "instructionsRequired", value: "true"))
        case .randomRecipes:
            components.path = "/recipes/random"
        case .scannerRecipes:
            components.path = "/recipes/complexSearch"
            components.queryItems?.append(URLQueryItem(name: "addRecipeInformation", value: "true"))
            components.queryItems?.append(URLQueryItem(name: "instructionsRequired", value: "true"))
            components.queryItems?.append(URLQueryItem(name: "sortDirection", value: "desc"))
            components.queryItems?.append(URLQueryItem(name: "sort", value: "min-missing-ingredients"))
        }

        return components
    }

    var parseType: RecipeContainer.Type {
        switch self {
        case .randomRecipes:
            return RandomRecipes.self
        case .searchRecipes:
            return SearchRecipes.self
        case .scannerRecipes:
            return SearchRecipes.self
        }
    }
}
