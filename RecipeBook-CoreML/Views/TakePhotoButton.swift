//
//  TakePictureButton.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 19/09/2023.
//

import Foundation

import UIKit

class CircleButton: UIImageView {
    let diameter: CGFloat

    let systemImage: String

    init(diameter: CGFloat = 75.0, systemImage: String) {
        self.diameter = diameter
        self.systemImage = systemImage
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        self.image = UIImage(systemName: self.systemImage)
        backgroundColor = UIColor.clear
        tintColor = UIColor.accentColor

        self.clipsToBounds = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: diameter),
            widthAnchor.constraint(equalToConstant: diameter),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
