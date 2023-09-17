//
//  RecipesFetcher.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import Foundation
import Combine

enum FetcherError: Error {
    case invalidUrl
    case invalidStatusCode
    case decodingError(error: Error)
    case other(description: String)
}

protocol RecipesFetcher {
    func fetchRecipes<T: RecipeContainer>(type: T.Type) -> AnyPublisher<[Recipe], FetcherError>
    var requestType: NetworkRecipesRequestType { get set }
}
