//
//  RecipesViewModel.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import Combine
import Foundation

final class RecipesViewModel {
    private(set) var recipes: [Recipe]
    private(set) var bag = Set<AnyCancellable>()
    private(set) var dataLoadingFinishedPublisher = PassthroughSubject<Void, Never>()

    var recipesFetcher: RecipesFetcher

    init(recipes: [Recipe] = [], recipesFetcher: RecipesFetcher = NetworkRecipesFetcher()) {
        self.recipes = recipes
        self.recipesFetcher = recipesFetcher
    }

    var optionalQueryItems: [URLQueryItem] = []

    func search(withQueryItems searchQueryStrings: [String]) {
        optionalQueryItems.removeAll()
        recipesFetcher.requestType = searchQueryStrings.last == "" ? .randomRecipes : .searchRecipes

        switch recipesFetcher.requestType {
        case .randomRecipes:
            optionalQueryItems.append(
                URLQueryItem(name: "tags",
                             value: Array(searchQueryStrings.prefix(2))
                                 .filter { $0 != "" }
                                 .joined(separator: ","))
            )
        case .searchRecipes:
            var queryItemsArray = [URLQueryItem]()
            let names = ["diet", "type", "intolerances", "query"]

            for (index, name) in names.enumerated() {
                if searchQueryStrings[index] == "" { continue }
                if index == 0 {
                    let veganAndVegetarian = searchQueryStrings.first == "vegetarian"

                    queryItemsArray.append(URLQueryItem(name: name,
                                                        value: veganAndVegetarian ? "vegan|vegetarian" : "vegan"))
                } else {
                    queryItemsArray.append(URLQueryItem(name: name, value: searchQueryStrings[index]))
                }
            }
            optionalQueryItems = queryItemsArray
        }

        loadRecipes()
    }

    func loadRecipes() {
        if let recipesFetcher = recipesFetcher as? NetworkRecipesFetcher {
            recipesFetcher.makeUrl(queryItems: optionalQueryItems)
        }
        print(recipesFetcher.requestType)

        recipesFetcher
            .fetchRecipes(type: recipesFetcher.requestType.parseType)
            .map { recipes in
                recipes.filter { !$0.analyzedInstructions.isEmpty }
            }
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    switch error {
                    case .decodingError(let error):
                        print(error)
                    case .other(let description):
                        print(description)
                    default:
                        print(error)
                    }
                case .finished:
                    print("successfully loaded recipes")
                    print(self.recipes.count)
                }
            } receiveValue: { [weak self] recipes in
                self?.recipes = recipes
                self?.dataLoadingFinishedPublisher.send(())
            }
            .store(in: &bag)
    }
}
