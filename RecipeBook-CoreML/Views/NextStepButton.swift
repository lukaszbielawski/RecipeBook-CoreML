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
    var innerLabel: NextStepButtonInnerLabel!

    init(stepNumber: Int) {
        self.stepNumber = stepNumber
        super.init(frame: .zero)
        setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        innerLabel = NextStepButtonInnerLabel()
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

class NextStepButtonInnerLabel: PaddingLabel {
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
