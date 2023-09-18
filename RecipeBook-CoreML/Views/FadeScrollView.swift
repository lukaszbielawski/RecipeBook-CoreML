//
//  FadeScrollView.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 13/09/2023.
//

import UIKit

final class FadeScrollView: UIScrollView {
    let fadePercentage: Double = 0.2
    let gradientLayer = CAGradientLayer()
    let transparentColor = UIColor.clear.cgColor
    let opaqueColor = UIColor.black.cgColor

    var topOpacity: CGColor {
        let scrollViewHeight = frame.size.height
        let scrollContentSizeHeight = contentSize.height
        let scrollOffset = contentOffset.y

        let alpha: CGFloat = (scrollViewHeight >= scrollContentSizeHeight || scrollOffset <= 0) ? 1 : 0

        let color = UIColor(white: 0, alpha: alpha)
        return color.cgColor
    }

    var bottomOpacity: CGColor {
        let scrollViewHeight = frame.size.height
        let scrollContentSizeHeight = contentSize.height
        let scrollOffset = contentOffset.y

        let alpha: CGFloat = (scrollViewHeight >= scrollContentSizeHeight ||
            scrollOffset + scrollViewHeight >= scrollContentSizeHeight) ? 1 : 0

        let color = UIColor(white: 0, alpha: alpha)
        return color.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let maskLayer = CALayer()
        maskLayer.frame = self.bounds

        self.gradientLayer.frame = CGRect(x: self.bounds.origin.x, y: 0,
                                          width: self.bounds.size.width,
                                          height: self.bounds.size.height)
        self.gradientLayer.colors = [self.topOpacity, self.opaqueColor, self.opaqueColor, self.bottomOpacity]
        self.gradientLayer.locations = [0,
                                        NSNumber(value: CGFloat(self.fadePercentage)),
                                        NSNumber(value: CGFloat(1.0 - self.fadePercentage)),
                                        1]
        maskLayer.addSublayer(self.gradientLayer)

        self.layer.mask = maskLayer
    }
}
