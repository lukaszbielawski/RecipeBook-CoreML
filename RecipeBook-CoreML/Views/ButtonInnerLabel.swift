//
//  NextStepButtonInnerLabel.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 16/09/2023.
//

import Foundation
import UIKit

final class ButtonInnerLabel: PaddingLabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 18)
        backgroundColor = .accentColor
        textColor = .white

        paddingTop = 4.0
        paddingBottom = 4.0
        paddingLeft = 8.0
        paddingRight = 8.0

        layer.cornerRadius = 12.0
        layer.masksToBounds = true
    }
}
