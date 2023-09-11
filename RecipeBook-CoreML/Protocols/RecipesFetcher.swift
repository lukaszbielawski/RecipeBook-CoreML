//
//  RecipesFetcher.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import Foundation
import Combine

protocol RecipesFetcher {
    func fetchRecipes() -> AnyPublisher<[Recipe], Error>
}
