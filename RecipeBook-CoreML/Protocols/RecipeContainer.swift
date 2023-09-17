//
//  RecipeContainer.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 17/09/2023.
//

import Foundation

protocol RecipeContainer: Decodable {
    func getRecipes() -> [Recipe]
}
