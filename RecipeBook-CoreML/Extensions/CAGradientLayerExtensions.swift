//
//  CAGradientLayer.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 13/09/2023.
//

import Foundation
import UIKit

extension CAGradientLayer {
    func calculateLocation(offset: CGFloat, maxOffset: CGFloat) {
        let calculatedOffset = offset / maxOffset

        if calculatedOffset > 0.4 {
            self.locations = [NSNumber(value:
                min(0.5, calculatedOffset <= 0.5 ? calculatedOffset : 0.5)),
            0.5,
            0.5,
            NSNumber(value:
                max(0.5, calculatedOffset <= 0.5 ? 1.0 - calculatedOffset : 0.5))]
        } else if calculatedOffset < 0.0 {
            self.locations = [0, 0.1, 0.9, 1]
        } else {
            self.locations = [NSNumber(value: CGFloat(calculatedOffset)),
                              NSNumber(value: CGFloat(calculatedOffset + 0.1)),
                              NSNumber(value: CGFloat(0.9 - calculatedOffset)),
                              NSNumber(value: CGFloat(1.0 - calculatedOffset))]
        }
    }
}
