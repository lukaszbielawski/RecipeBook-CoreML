//
//  TagType.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 16/09/2023.
//

import Foundation

enum TabType {
    case recipes
    case scanner

    var title: String {
        switch self {
        case .recipes:
            return "Explore recipes"
        case .scanner:
            return "Scan"
        }
    }
}
