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
    private(set) var bag =  Set<AnyCancellable>()

    var recipesFetcher: RecipesFetcher

    init(recipes: [Recipe] = [], recipesFetcher: RecipesFetcher = FakeRecipesFetcher.shared) {
        self.recipes = recipes
        self.recipesFetcher = recipesFetcher
    }

    func loadRecipes() {
        recipesFetcher
            .fetchRecipes()
            .sink { completion in
                switch completion {
                case .failure:
                    print("loader failed")
                case .finished:
                    print("successfully loaded recipes")
                    print(self.recipes.count)
                }
            } receiveValue: { [weak self] recipes in
                self?.recipes += recipes
            }
            .store(in: &bag)
    }
}
