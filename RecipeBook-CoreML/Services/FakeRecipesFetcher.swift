//
//  FakeRecipesFetcher.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import Foundation
import Combine

class FakeRecipesFetcher: RecipesFetcher {
    static var shared = FakeRecipesFetcher()

    private init() {}

    func fetchRecipes() -> AnyPublisher<[Recipe], Error> {
        Bundle
            .main
            .url(forResource: "fakeData", withExtension: "json")
            .publisher
            .tryMap { string in
                guard let data = try? Data(contentsOf: string) else {
                    fatalError("failed")
                }
                return data
            }
            .decode(type: Recipes.self, decoder: JSONDecoder())
            .map { recipes in
                return recipes.recipes
            }
            .eraseToAnyPublisher()
    }
}
