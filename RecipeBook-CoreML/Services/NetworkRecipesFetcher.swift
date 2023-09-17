//
//  RecipesFetcher.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import Combine
import Foundation

class NetworkRecipesFetcher: RecipesFetcher {
    var requestType: NetworkRecipesRequestType = .randomRecipes

    var url: URL?

    func makeUrl(queryItems: [URLQueryItem] = []) {
        var components = requestType.urlComponents
        components.queryItems? += queryItems

        url = components.url
    }

    func fetchRecipes<T>(type: T.Type) -> AnyPublisher<[Recipe], FetcherError> where T: RecipeContainer {
        guard let url else {
            return Fail(error: FetcherError.invalidUrl).eraseToAnyPublisher()
        }
        print(url)
//        return Fail(error: FetcherError.invalidStatusCode).eraseToAnyPublisher()
        return URLSession
            .shared
            .dataTaskPublisher(for: url)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw FetcherError.invalidStatusCode
                }
                return output.data
            }
            .decode(type: type, decoder: JSONDecoder())
            .mapError { error in FetcherError.decodingError(error: error) }
            .map { recipeContainer in
                recipeContainer.getRecipes()
            }
            .eraseToAnyPublisher()
    }
}
