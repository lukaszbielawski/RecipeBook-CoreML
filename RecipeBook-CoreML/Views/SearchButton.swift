//
//  SearchButton.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 17/09/2023.
//

import Foundation
import UIKit

final class SearchButton: UIButton {
    let innerLabel = ButtonInnerLabel()

    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        layer.opacity = 1.0
        addSubview(innerLabel)

        innerLabel.text = "Search"

        NSLayoutConstraint.activate([
            innerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            innerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            innerLabel.topAnchor.constraint(equalTo: topAnchor),
            innerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
