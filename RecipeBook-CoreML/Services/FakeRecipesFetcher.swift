//
//  FakeRecipesFetcher.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import Combine
import Foundation

final class FakeRecipesFetcher: RecipesFetcher {
    var requestType: NetworkRecipesRequestType = .randomRecipes

    func fetchRecipes<T: RecipeContainer>(type: T.Type) -> AnyPublisher<[Recipe], FetcherError> {
        Bundle
            .main
            .url(forResource: "fakeData", withExtension: "json")
            .publisher
            .tryMap { string in
                guard let data = try? Data(contentsOf: string) else {
                    throw FetcherError.other(description: "json decoding error")
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                FetcherError.decodingError(error: error)
            }
            .map { recipes in
                recipes.getRecipes()
            }
            .eraseToAnyPublisher()
    }
}
