//
//  DetailsViewModel.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 15/09/2023.
//

import Combine
import Foundation
import UIKit

final class DetailsViewModel {
    var ingredientsData: [Ingredient] = []
    var recipe: Recipe
    var image: UIImage

    typealias Ingredient = (stepNumber: Int, name: String, image: UIImage)

    init(recipe: Recipe, image: UIImage) {
        self.recipe = recipe
        self.image = image
    }

    func loadStepImages() async {
        do {
            try await withThrowingTaskGroup(of: Ingredient.self) { group in
                for step in self.recipe.analyzedInstructions.first!.steps {
                    for ingredient in step.ingredients {
                        group.addTask {
                            try await (step.number,
                                       ingredient.name,
                                       ImageDownloader.shared.downloadImage(
                                           from: "https://spoonacular.com/cdn/ingredients_500x500/\(ingredient.image)",
                                           crop: false))
                        }
                    }
                    guard step.ingredients.isEmpty, !step.equipment.isEmpty else {
                        continue
                    }
                    for equipment in step.equipment {
                        group.addTask {
                            try await (step.number,
                                       equipment.name,
                                       ImageDownloader.shared.downloadImage(
                                           from: "https://spoonacular.com/cdn/equipment_500x500/\(equipment.image)",
                                           crop: false))
                        }
                    }
                }
                for try await ingredient in group {
                    self.ingredientsData.append(ingredient)
                }
            }
        } catch {
            print(error)
        }
    }

    func animationFunction(value: Double) -> Double {
        return 0.5 * (1 - cos(.pi * value))
    }

    func derivativeOf(function: (Double) -> Double, atX x: Double) -> Double {
        let difference = 0.0000001
        return (function(x + difference) - function(x)) / difference
    }
}
