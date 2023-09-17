//
//  DetailsViewController.swift
//  vm.recipeBook-CoreML
//
//  Created by Łukasz Bielawski on 13/09/2023.
//

import Combine
import Foundation
import UIKit

final class DetailsViewController: UIViewController {
    private var instructionLabelConstraint: NSLayoutConstraint?
    private var nextStepButtonConstraint: NSLayoutConstraint?
    private var stepLabelConstraint: NSLayoutConstraint?
    private var animationSubscribtion: AnyCancellable?
    private var stepInstructionViewsArray: [UIView] = []
    private let vm: DetailsViewModel

    private var lastContentOffset: CGFloat = 0
    private lazy var stepOffset: CGFloat = (view.layer.bounds.height * 0.50)

    var currentStep: Double = 0 {
        didSet {
            if floor(currentStep) != floor(oldValue) {
                setStep(step: Int(currentStep))
            }
        }
    }

    typealias Ingredient = DetailsViewModel.Ingredient

    lazy var detailsTitleLabel = {
        let detailsTitleLabel = UILabel()
        detailsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsTitleLabel.textColor = .secondaryColor
        detailsTitleLabel.numberOfLines = 0
        detailsTitleLabel.textAlignment = .center
        detailsTitleLabel.font = UIFont.systemFont(ofSize: 27.0, weight: .bold)
        detailsTitleLabel.adjustsFontSizeToFitWidth = true
        detailsTitleLabel.text = vm.recipe.title
        return detailsTitleLabel
    }()

    lazy var estimatedTimeLabel: UILabel = {
        let estimatedTimeLabel = UILabel()
        estimatedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        estimatedTimeLabel.textColor = UIColor.secondaryColor
        estimatedTimeLabel.numberOfLines = 0
        estimatedTimeLabel.textAlignment = .center
        estimatedTimeLabel.font = UIFont.systemFont(ofSize: 22, weight: .thin)
        estimatedTimeLabel.text = "Estimated time: about \(vm.recipe.readyInMinutes) minutes."
        return estimatedTimeLabel
    }()

    lazy var instructionsScrollView = {
        let instructionsScrollView = FadeScrollView()
        instructionsScrollView.translatesAutoresizingMaskIntoConstraints = false
        instructionsScrollView.showsVerticalScrollIndicator = false
        instructionsScrollView.delegate = self
        instructionsScrollView.backgroundColor = UIColor.clear

        return instructionsScrollView
    }()

    lazy var instructionsStackView = {
        let scrollStackViewContainer = UIStackView()
        scrollStackViewContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollStackViewContainer.axis = .vertical
        scrollStackViewContainer.spacing = 0
        return scrollStackViewContainer
    }()

    lazy var ingredientsScrollView: UIScrollView = {
        let ingredientsScrollView = UIScrollView()
        ingredientsScrollView.translatesAutoresizingMaskIntoConstraints = false
        ingredientsScrollView.showsHorizontalScrollIndicator = false
        ingredientsScrollView.layer.opacity = 0.0
        return ingredientsScrollView
    }()

    lazy var ingredientsStackView: UIStackView = {
        let ingredientsStackView = UIStackView()
        ingredientsStackView.spacing = 8
        ingredientsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        ingredientsStackView.isLayoutMarginsRelativeArrangement = true
        ingredientsStackView.translatesAutoresizingMaskIntoConstraints = false
        ingredientsStackView.backgroundColor = UIColor.clear
        ingredientsStackView.axis = .horizontal
        return ingredientsStackView
    }()

    lazy var instructionsLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = UIColor.secondaryColor
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 27.0, weight: .bold)
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.text = "Instructions"
        return descriptionLabel
    }()

    lazy var imageGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.backgroundColor.withAlphaComponent(0.0).cgColor,
                                UIColor.backgroundColor.cgColor,
                                UIColor.backgroundColor.cgColor,
                                UIColor.backgroundColor.withAlphaComponent(0.0).cgColor]

        gradientLayer.locations = [0.0, 0.1, 0.9, 1.0]
        return gradientLayer
    }()

    lazy var detailImageView = {
        let detailImageView = UIImageView()
        detailImageView.translatesAutoresizingMaskIntoConstraints = false
        detailImageView.backgroundColor = .secondaryColor
        detailImageView.contentMode = .scaleAspectFill
        detailImageView.image = vm.image
        return detailImageView
    }()

    init(recipe: Recipe, image: UIImage) {
        self.vm = DetailsViewModel(recipe: recipe, image: image)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupLayers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        Task {
            await vm.loadStepImages()
        }
        setupInstructions()
    }
}

extension DetailsViewController {
    func setupConstraints() {
        view.backgroundColor = .backgroundColor
        view.addSubview(detailsTitleLabel)
        view.addSubview(instructionsScrollView)
        view.addSubview(detailImageView)
        view.addSubview(instructionsLabel)
        view.addSubview(ingredientsScrollView)
        view.addSubview(estimatedTimeLabel)
        ingredientsScrollView.addSubview(ingredientsStackView)
        instructionsScrollView.addSubview(instructionsStackView)

        NSLayoutConstraint.activate([
            detailsTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -45),
            detailsTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            detailsTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            //
            instructionsScrollView.topAnchor.constraint(equalTo: detailImageView.centerYAnchor, constant: 32),
            instructionsScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            instructionsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            //
            detailImageView.topAnchor.constraint(equalTo: detailsTitleLabel.bottomAnchor, constant: 8),
            detailImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailImageView.widthAnchor.constraint(equalToConstant: CGFloat(Int(UIScreen.main.bounds.width))),
            detailImageView.heightAnchor.constraint(equalToConstant: CGFloat(Int(UIScreen.main.bounds.width))),
            //
            instructionsStackView.bottomAnchor.constraint(equalTo: instructionsScrollView.bottomAnchor),
            instructionsStackView.leadingAnchor.constraint(equalTo: instructionsScrollView.leadingAnchor),
            instructionsStackView.trailingAnchor.constraint(equalTo: instructionsScrollView.trailingAnchor),
            instructionsStackView.widthAnchor.constraint(equalTo: instructionsScrollView.widthAnchor),
            //
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            //
            ingredientsScrollView.topAnchor.constraint(equalTo: detailsTitleLabel.bottomAnchor, constant: 16),
            ingredientsScrollView.bottomAnchor.constraint(equalTo: detailImageView.centerYAnchor, constant: -16),
            ingredientsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ingredientsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            //
            ingredientsStackView.topAnchor.constraint(equalTo: ingredientsScrollView.topAnchor),
            ingredientsStackView.bottomAnchor.constraint(equalTo: ingredientsScrollView.bottomAnchor),
            ingredientsStackView.leadingAnchor.constraint(equalTo: ingredientsScrollView.leadingAnchor),
            ingredientsStackView.trailingAnchor.constraint(equalTo: ingredientsScrollView.trailingAnchor),
            //
            estimatedTimeLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            estimatedTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            estimatedTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
        ])
    }

    func setupInstructions() {
        for step in 0 ..< vm.recipe.analyzedInstructions.first!.steps.count {
            let stepView = makeStepInstructionsView(step: vm.recipe.analyzedInstructions.first!.steps[step])
            stepInstructionViewsArray.append(stepView)
            instructionsStackView.addArrangedSubview(stepView)
        }
    }

    func setupLayers() {
        detailImageView.layoutIfNeeded()
        ingredientsStackView.layoutIfNeeded()
        ingredientsScrollView.layoutIfNeeded()

        if ingredientsScrollView.contentSize.width == 0.0 {
            ingredientsScrollView.contentSize = CGSize(
                width: ingredientsScrollView.frame.size.width * 2,
                height: ingredientsScrollView.frame.size.height)
        }

        instructionsStackView.topAnchor.constraint(equalTo: instructionsScrollView.topAnchor,
                                                   constant: detailImageView.frame.height / 2).isActive = true
        if instructionLabelConstraint == nil {
            instructionLabelConstraint =
                instructionsLabel.bottomAnchor.constraint(equalTo: instructionsScrollView.topAnchor,
                                                          constant: detailImageView.frame.height / 2)
            instructionLabelConstraint?.isActive = true
        }

        imageGradientLayer.frame = detailImageView.bounds
        detailImageView.layer.mask = imageGradientLayer
    }

    private func setStep(step: Int) {
        guard step > -1 else { return }
        ingredientsStackView.removeAllArrangedSubviews()
        for ingredient in vm.ingredientsData.filter({ $0.stepNumber == step }) {
            ingredientsStackView.addArrangedSubview(makeIngredientView(ingredient: ingredient))
        }
    }

    private func makeIngredientView(ingredient: Ingredient) -> UIView {
        let ingredientView = UIView()
        ingredientView.translatesAutoresizingMaskIntoConstraints = false

        let ingredientLabel = makeIngredientLabel(named: ingredient.name)
        let ingredientImageView = makeIngredientImageView(image: ingredient.image)

        ingredientView.addSubview(ingredientLabel)
        ingredientView.addSubview(ingredientImageView)

        NSLayoutConstraint.activate([
            ingredientLabel.topAnchor.constraint(equalTo: ingredientView.topAnchor),
            ingredientLabel.leadingAnchor.constraint(equalTo: ingredientView.leadingAnchor),
            ingredientLabel.trailingAnchor.constraint(equalTo: ingredientView.trailingAnchor),
            ingredientImageView.topAnchor.constraint(equalTo: ingredientLabel.bottomAnchor, constant: 8),
            ingredientImageView.bottomAnchor.constraint(equalTo: ingredientView.bottomAnchor),
            ingredientImageView.leadingAnchor.constraint(equalTo: ingredientView.leadingAnchor),
            ingredientImageView.trailingAnchor.constraint(equalTo: ingredientView.trailingAnchor),

        ])

        return ingredientView
    }

    private func makeIngredientLabel(named: String) -> UILabel {
        let ingredientLabel = UILabel()
        ingredientLabel.translatesAutoresizingMaskIntoConstraints = false
        ingredientLabel.textColor = UIColor.secondaryColor
        ingredientLabel.numberOfLines = 1
        ingredientLabel.adjustsFontSizeToFitWidth = true
        ingredientLabel.minimumScaleFactor = 0.9
        ingredientLabel.textAlignment = .center
        ingredientLabel.text = named
        return ingredientLabel
    }

    private func makeIngredientImageView(image: UIImage) -> UIImageView {
        let ingredientImageView = UIImageView()

        ingredientImageView.translatesAutoresizingMaskIntoConstraints = false
        ingredientImageView.backgroundColor = .secondaryColor
        ingredientImageView.contentMode = .scaleToFill
        ingredientImageView.layer.cornerRadius = 16.0
        ingredientImageView.image = image

        ingredientImageView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            ingredientImageView.heightAnchor.constraint(
                equalToConstant: ingredientsScrollView.layer.bounds.height * 0.75),
            ingredientImageView.widthAnchor.constraint(
                equalToConstant: ingredientsScrollView.layer.bounds.height * 0.75),
        ])
        return ingredientImageView
    }

    private func makeStepInstructionsView(step: Step) -> UIView {
        let isLast = step.number == vm.recipe.analyzedInstructions.first!.steps.count

        let stepInstructionsView = UIView()
        stepInstructionsView.translatesAutoresizingMaskIntoConstraints = false
        stepInstructionsView.layer.masksToBounds = true

        let stepInstructionsLabel = makeStepInstructionsLabel(step: step)
        stepInstructionsView.addSubview(stepInstructionsLabel)

        NSLayoutConstraint.activate([
            stepInstructionsLabel.leadingAnchor.constraint(equalTo: stepInstructionsView.leadingAnchor),
            stepInstructionsLabel.trailingAnchor.constraint(equalTo: stepInstructionsView.trailingAnchor),
            stepInstructionsView.heightAnchor.constraint(equalToConstant: stepOffset),
        ])

        let nextStepButton = NextStepButton(stepNumber: step.number)
        nextStepButton.addTarget(self,
                                 action: isLast ? #selector(startOverButtonAction) : #selector(nextButtonAction),
                                 for: .touchDown)

        stepInstructionsView.addSubview(nextStepButton)

        if step.number == 1 {
            stepInstructionsLabel.layer.opacity = 0.0
            nextStepButton.innerText = "Let's start"

            if nextStepButtonConstraint == nil, stepLabelConstraint == nil {
                nextStepButtonConstraint = nextStepButton.topAnchor.constraint(
                    equalTo: stepInstructionsView.topAnchor, constant: 8)
                nextStepButtonConstraint?.isActive = true

                stepLabelConstraint = stepInstructionsLabel.topAnchor.constraint(
                    equalTo: nextStepButton.bottomAnchor, constant: 8)
                stepLabelConstraint?.isActive = true
            }
        } else if !isLast {
            nextStepButton.innerText = "Next step"
            stepInstructionsLabel.topAnchor.constraint(
                equalTo: stepInstructionsView.topAnchor, constant: 16).isActive = true
            nextStepButton.topAnchor.constraint(
                equalTo: stepInstructionsLabel.bottomAnchor, constant: 8).isActive = true
        } else {
            nextStepButton.innerText = "Start over"
            nextStepButton.innerLabel.backgroundColor = .systemBlue
            stepInstructionsLabel.topAnchor.constraint(
                equalTo: stepInstructionsView.topAnchor, constant: 16).isActive = true
            nextStepButton.topAnchor.constraint(
                equalTo: stepInstructionsLabel.bottomAnchor, constant: 8).isActive = true
        }

        NSLayoutConstraint.activate([
            stepInstructionsLabel.centerXAnchor.constraint(equalTo: nextStepButton.centerXAnchor),

        ])
        return stepInstructionsView
    }

    @objc private func startOverButtonAction() {
        let targetOffset = stepInstructionViewsArray.first!.layer.position.y
            - 60

        UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseInOut, animations: {
            self.instructionsStackView.layer.opacity = 0.0
            self.ingredientsStackView.layer.opacity = 0.0
            self.instructionsLabel.layer.opacity = 0.0
        }, completion: { _ in
            self.instructionsScrollView.contentOffset.y = targetOffset
            UIView.animate(withDuration: 0.75, delay: 0.2, options: .curveEaseInOut, animations: {
                self.instructionsStackView.layer.opacity = 1.0
                self.ingredientsStackView.layer.opacity = 1.0
                self.instructionsLabel.layer.opacity = 1.0
            })
        })
    }

    @objc private func nextButtonAction(sender: NextStepButton) {
        sender.stepNumber = sender.stepNumber < 2 ? Int(currentStep) : sender.stepNumber

        let initialOffset = instructionsScrollView.contentOffset.y
        let targetOffset = stepInstructionViewsArray[sender.stepNumber].layer.position.y - 60

        let frames = 120.0

        let difference = targetOffset - initialOffset

        animationSubscribtion = Timer
            .publish(every: 1.0 / frames, on: RunLoop.main, in: .default)
            .autoconnect()
            .scan(0.0) { sum, _ in
                sum + 1.0 / frames
            }
            .sink { [weak self] value in
                guard let self = self else { return }
                let modifiedValue = vm.animationFunction(value: value)

                let newOffset = initialOffset + difference * modifiedValue

                let left = abs(newOffset - lastContentOffset)
                let right = difference / frames
                    * vm.derivativeOf(function: vm.animationFunction, atX: value) * 3

                if value > 1.0 / frames, left > right {
                    animationSubscribtion?.cancel()
                    return
                }
                self.instructionsScrollView.contentOffset.y = newOffset

                if value >= 1.0 {
                    animationSubscribtion?.cancel()
                }
            }
    }

    private func makeStepInstructionsLabel(step: Step) -> UILabel {
        let stepLabel = UILabel()
        stepLabel.translatesAutoresizingMaskIntoConstraints = false

        let stepLabelContent = "\(step.number.romanNumeral)\n\(step.step.insertNewlineAfterEndOfSentence)"

        let attributedString =
            NSMutableAttributedString(string: stepLabelContent, attributes:
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: .thin)])
        let boldFontAttribute = [NSAttributedString.Key.font:
            UIFont.systemFont(ofSize: 24.0, weight: .bold)]
        attributedString.addAttributes(boldFontAttribute,
                                       range: NSRange(location: 0, length: step.number.romanNumeral.count))

        stepLabel.attributedText = attributedString

        stepLabel.textAlignment = .center
        stepLabel.numberOfLines = 0

        return stepLabel
    }
}

extension DetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffset: CGFloat = 116

        imageGradientLayer.calculateLocation(offset: lastContentOffset, maxOffset: maxOffset)
        instructionsScrollView.gradientLayer.colors = [instructionsScrollView.topOpacity,
                                                       instructionsScrollView.opaqueColor,
                                                       instructionsScrollView.opaqueColor,
                                                       instructionsScrollView.bottomOpacity]

        lastContentOffset = scrollView.contentOffset.y

        currentStep = min(
            (stepOffset * 0.93 + lastContentOffset) / stepOffset,
            Double(vm.recipe.analyzedInstructions.first!.steps.count) + 0.99)

        instructionLabelConstraint!.constant = max(0, ceil(detailImageView.frame.height / 2 - lastContentOffset))

        let currentStepFloatReminder = currentStep.truncatingRemainder(dividingBy: 1)

        if (0.0...0.1).contains(currentStepFloatReminder) ||
            (0.9...1.0).contains(currentStepFloatReminder)
        {
            ingredientsScrollView.layer.opacity = 0
        } else if (0.1...0.29).contains(currentStepFloatReminder) ||
            (0.71...0.9).contains(currentStepFloatReminder)
        {
            let opacityValue = Float(currentStepFloatReminder > 0.5
                ? (0.9 - currentStepFloatReminder) * (100 / 19) : (currentStepFloatReminder - 0.1) * (100 / 19))
            ingredientsScrollView.layer.opacity = opacityValue
        } else {
            ingredientsScrollView.layer.opacity = 1
        }

        let unsignedVariable = (currentStep - 1.04) / 0.25

        let variable = min(max(unsignedVariable, 0.0), 1.0)

        let nextStepButton = stepInstructionViewsArray.first!.subviews
            .first(where: { type(of: $0) == NextStepButton.self })! as! NextStepButton

        let nextStepInstructionsLabel = stepInstructionViewsArray.first!.subviews
            .first(where: { type(of: $0) == UILabel.self })! as! UILabel

        nextStepButton.innerLabel?.textColor =
            UIColor.white.withAlphaComponent(CGFloat(Float(abs(unsignedVariable) * 2)))
        nextStepButton.innerLabel?.text = variable < 0.01 ? "Let's start" : "Next step"

        nextStepInstructionsLabel.layer.opacity = Float(variable)

        estimatedTimeLabel.layer.opacity = 1 - Float(variable)

        nextStepButton.stepNumber = currentStep < 2.0 ? Int(currentStep) : nextStepButton.stepNumber

        stepLabelConstraint!.constant =
            -variable * (16 + nextStepInstructionsLabel.layer.bounds.height + nextStepButton.layer.bounds.height) + 8
        nextStepButtonConstraint!.constant
            = variable * (8 + nextStepInstructionsLabel.layer.bounds.height) + 8
    }
}
