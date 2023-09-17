//
//  Taggable.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 16/09/2023.
//

import Foundation
import UIKit

protocol Taggable: UIViewController {
    var tag: TabType { get set }
}
