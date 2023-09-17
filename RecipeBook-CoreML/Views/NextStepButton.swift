//
//  StepButton.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 15/09/2023.
//

import UIKit

class NextStepButton: UIButton {
    var innerText: String = "" {
        didSet {
            innerLabel?.text = innerText
        }
    }

    var stepNumber: Int
    var innerLabel: ButtonInnerLabel!

    init(stepNumber: Int) {
        self.stepNumber = stepNumber
        super.init(frame: .zero)
        setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        innerLabel = ButtonInnerLabel()
        layer.opacity = 1.0
        addSubview(innerLabel)

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: innerLabel.centerXAnchor),
            centerYAnchor.constraint(equalTo: innerLabel.centerYAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
