//
//  DetailsViewController.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 13/09/2023.
//

import Combine
import Foundation
import UIKit

// swiftlint:disable type_body_length

final class DetailsViewController: UIViewController {
    var recipe: Recipe
    var image: UIImage
    private var lastContentOffset: CGFloat = 0
    private var descriptionLabelConstraint: NSLayoutConstraint?
    private lazy var stepOffset = (view.layer.bounds.height * 0.5)
    private var stepViewsArray: [UIView] = []
    private var ingredientsData: [Ingredient] = []
    private var cancellable: AnyCancellable?

    typealias Ingredient = (stepNumber: Int, name: String, image: UIImage)

    private var currentStep: Int = 0 {
        didSet {
            if currentStep != oldValue {
                print("set \(currentStep)")
                if oldValue == 0 {
                    let innerButton = stepViewsArray.first?.subviews
                        .first(where: { type(of: $0) == UIButton.self })
                    let innerLabel = innerButton?.subviews.first(where: { type(of: $0) == PaddingLabel.self }) as? PaddingLabel
//                    innerButton?.removeConstraints(innerButton?.constraints ?? [])
                    
                    
//                    innerLabel?.text = "Let's start"
//                    nextStepButton.topAnchor.constraint(equalTo: stepView.topAnchor, constant: 8).isActive = true
//                    stepLabel.topAnchor.constraint(equalTo: nextStepButton.bottomAnchor, constant: 8).isActive = true
//                } else {
//                    innerLabel.text = "Next step"
//                    stepLabel.topAnchor.constraint(equalTo: stepView.topAnchor, constant: 16).isActive = true
//                    nextStepButton.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 8).isActive = true

                    innerLabel?.text = "Next step"
                } else if currentStep == 0 {
                    let innerButton = stepViewsArray.first?.subviews
                        .first(where: { type(of: $0) == UIButton.self })
                    let innerLabel = innerButton?.subviews.first(where: { type(of: $0) == PaddingLabel.self }) as? PaddingLabel
                    innerLabel?.text = "Let's start"
                }
                setStep(step: currentStep)
            }
        }
    }

    private var aspectRatioFontFactor: CGFloat {
        let deviceWidth = UIScreen.main.bounds.width * UIScreen.main.scale
        let deviceHeight = UIScreen.main.bounds.height * UIScreen.main.scale
        let testDeviceAspectRatio = deviceHeight / deviceWidth

        return testDeviceAspectRatio > 2.0 ? 2 / testDeviceAspectRatio : 1.0 + abs(testDeviceAspectRatio - 2)
    }

    lazy var detailsTitleLabel = {
        let detailsTitleLabel = UILabel()
        detailsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsTitleLabel.textColor = .secondaryColor
        detailsTitleLabel.numberOfLines = 0
        detailsTitleLabel.textAlignment = .center
        detailsTitleLabel.font = UIFont.systemFont(ofSize: 36.0, weight: .bold)
        detailsTitleLabel.adjustsFontSizeToFitWidth = true
        detailsTitleLabel.text = recipe.title

        return detailsTitleLabel
    }()

    lazy var fadeScrollView = {
        let fadeScrollView = FadeScrollView()
        fadeScrollView.translatesAutoresizingMaskIntoConstraints = false
        fadeScrollView.showsVerticalScrollIndicator = false
        fadeScrollView.delegate = self
        fadeScrollView.backgroundColor = UIColor.clear

        return fadeScrollView
    }()

    lazy var scrollStackViewContainer = {
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
        descriptionLabel.font = UIFont.systemFont(ofSize: 27.0 * aspectRatioFontFactor, weight: .bold)
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
        detailImageView.image = image
        return detailImageView
    }()

    init(recipe: Recipe, image: UIImage) {
        self.recipe = recipe
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupLayers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        Task {
            await loadStepImages()
        }
        setupInstructions()
    }

    func setupConstraints() {
        view.backgroundColor = .backgroundColor

        view.addSubview(detailsTitleLabel)
        view.addSubview(fadeScrollView)
        view.addSubview(detailImageView)
        view.addSubview(instructionsLabel)
        view.addSubview(ingredientsScrollView)
        ingredientsScrollView.addSubview(ingredientsStackView)
        fadeScrollView.addSubview(scrollStackViewContainer)

        NSLayoutConstraint.activate([
            detailsTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            detailsTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            detailsTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            //
            fadeScrollView.topAnchor.constraint(equalTo: detailImageView.centerYAnchor, constant: 32),
            fadeScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fadeScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fadeScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            //
            detailImageView.topAnchor.constraint(equalTo: detailsTitleLabel.bottomAnchor, constant: 8),
            detailImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailImageView.widthAnchor.constraint(equalToConstant: CGFloat(Int(UIScreen.main.bounds.width))),
            detailImageView.heightAnchor.constraint(equalToConstant: CGFloat(Int(UIScreen.main.bounds.width))),
            //
            scrollStackViewContainer.bottomAnchor.constraint(equalTo: fadeScrollView.bottomAnchor),
            scrollStackViewContainer.leadingAnchor.constraint(equalTo: fadeScrollView.leadingAnchor),
            scrollStackViewContainer.trailingAnchor.constraint(equalTo: fadeScrollView.trailingAnchor),
            scrollStackViewContainer.widthAnchor.constraint(equalTo: fadeScrollView.widthAnchor),
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

        ])
    }

    func loadStepImages() async {
        do {
            try await withThrowingTaskGroup(of: Ingredient.self) { group in
                for step in self.recipe.analyzedInstructions.first!.steps {
                    for ingredient in step.ingredients {
                        group.addTask {
                            try await (step.number,
                                       ingredient.name,
                                       ImageDownloader.shared.downloadImage(
                                           from: "https://spoonacular.com/cdn/ingredients_500x500/\(ingredient.image)",
                                           crop: false))
                        }
                    }
                    guard step.ingredients.isEmpty && !step.equipment.isEmpty else {
                        continue
                    }
                    for equipment in step.equipment {
                        group.addTask {
                            try await (step.number,
                                       equipment.name,
                                       ImageDownloader.shared.downloadImage(
                                           from: "https://spoonacular.com/cdn/equipment_500x500/\(equipment.image)",
                                           crop: false))
                        }
                    }
                }
                for try await ingredient in group {
                    self.ingredientsData.append(ingredient)
                }

                currentStep = 0
            }
        } catch {
            print(error)
        }
    }

    func setupInstructions() {
        for step in 0 ..< recipe.analyzedInstructions.first!.steps.count {
            let stepView = makeStepView(step: recipe.analyzedInstructions.first!.steps[step])
            stepViewsArray.append(stepView)
            scrollStackViewContainer.addArrangedSubview(stepView)
        }
    }

    func setupLayers() {
        detailImageView.layoutIfNeeded()
        ingredientsStackView.layoutIfNeeded()
        ingredientsScrollView.layoutIfNeeded()

        if ingredientsScrollView.contentSize.width == 0.0 {
            ingredientsScrollView.contentSize = CGSize(width: ingredientsScrollView.frame.size.width * 2, height: ingredientsScrollView.frame.size.height)
        }

        scrollStackViewContainer.topAnchor.constraint(equalTo: fadeScrollView.topAnchor,
                                                      constant: detailImageView.frame.height / 2).isActive = true
        if descriptionLabelConstraint == nil {
            descriptionLabelConstraint =
                instructionsLabel.bottomAnchor.constraint(equalTo: fadeScrollView.topAnchor,
                                                          constant: detailImageView.frame.height / 2)
            descriptionLabelConstraint?.isActive = true
        }

        imageGradientLayer.frame = detailImageView.bounds
        detailImageView.layer.mask = imageGradientLayer
    }

    private func setStep(step: Int) {
        guard step > -1 else { return }
        ingredientsStackView.removeAllArrangedSubviews()
        for ingredient in ingredientsData.filter({ $0.stepNumber == step }) {
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
        ingredientLabel.textAlignment = .center
//        ingredientLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
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
            ingredientImageView.heightAnchor.constraint(equalToConstant: ingredientsScrollView.layer.bounds.height * 0.75),
            ingredientImageView.widthAnchor.constraint(equalToConstant: ingredientsScrollView.layer.bounds.height * 0.75),
        ])
        return ingredientImageView
    }

    private func makeStepView(step: Step) -> UIView {
        let stepView = UIView()
        stepView.translatesAutoresizingMaskIntoConstraints = false
        stepView.layer.masksToBounds = true

        let stepLabel = makeStepLabel(step: step)
        stepView.addSubview(stepLabel)

        NSLayoutConstraint.activate([
            stepLabel.leadingAnchor.constraint(equalTo: stepView.leadingAnchor),
            stepLabel.trailingAnchor.constraint(equalTo: stepView.trailingAnchor),
            stepView.heightAnchor.constraint(equalToConstant: stepOffset),
        ])

        if recipe.analyzedInstructions.first!.steps.last!.number != step.number {
            let nextStepButton = UIButton(type: .roundedRect)
            nextStepButton.translatesAutoresizingMaskIntoConstraints = false

            let innerLabel = PaddingLabel()
            nextStepButton.addSubview(innerLabel)
            innerLabel.translatesAutoresizingMaskIntoConstraints = false

            innerLabel.font = UIFont.systemFont(ofSize: 18)
            innerLabel.backgroundColor = .accentColor
            innerLabel.textColor = .white

            innerLabel.paddingTop = 4.0
            innerLabel.paddingBottom = 4.0
            innerLabel.paddingLeft = 8.0
            innerLabel.paddingRight = 8.0

            innerLabel.layer.cornerRadius = 12.0
            innerLabel.layer.masksToBounds = true

            nextStepButton.layer.opacity = 1.0
            nextStepButton.addTarget(self, action: #selector(nextButtonAction), for: .touchDown)

            stepView.addSubview(nextStepButton)

            if step.number == 1 {
//                stepLabel.isHidden = true
                innerLabel.text = "Let's start"
                nextStepButton.topAnchor.constraint(equalTo: stepView.topAnchor, constant: 8).isActive = true
                stepLabel.topAnchor.constraint(equalTo: nextStepButton.bottomAnchor, constant: 8).isActive = true
            } else {
                innerLabel.text = "Next step"
                stepLabel.topAnchor.constraint(equalTo: stepView.topAnchor, constant: 16).isActive = true
                nextStepButton.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 8).isActive = true
            }

            NSLayoutConstraint.activate([
                stepLabel.centerXAnchor.constraint(equalTo: nextStepButton.centerXAnchor),
                innerLabel.centerYAnchor.constraint(equalTo: nextStepButton.centerYAnchor),
                innerLabel.centerXAnchor.constraint(equalTo: nextStepButton.centerXAnchor),
            ])
        } else {
            // TODO: nowa funkcjonalnosc po ostatnim przycisku
            // TODO: na step 0 dodaj przyciski i schowaj stepviews
        }

        return stepView
    }

    @objc private func nextButtonAction() {
        let previousValue = currentStep == 0 ? 0.0 : stepViewsArray[currentStep - 1].layer.position.y - 60
        let offsetValue = stepViewsArray[currentStep].layer.position.y - 60
        let difference = offsetValue - previousValue
        let frames = 120.0

        cancellable = Timer
            .publish(every: 1.0 / frames, on: RunLoop.main, in: .default)
            .autoconnect()
            .scan(0.0) { sum, _ in
                sum + 1.0 / frames
            }
            .sink { [weak self] value in
                let modValue = 0.5 * (1 - cos(.pi * value))
                guard let self = self else { return }
                self.fadeScrollView.setContentOffset(CGPoint(x: 0.0,
                                                             y: previousValue + difference * modValue),
                                                     animated: false)
                if value >= 1.0 {
                    cancellable?.cancel()
                }
            }
    }

    private func makeStepLabel(step: Step) -> UILabel {
        let stepLabel = UILabel()
        stepLabel.translatesAutoresizingMaskIntoConstraints = false

        let stepLabelContent = "\(step.number.romanNumeral)\n\(step.step.insertNewlineAfterEndOfSentence)"

        let attributedString =
            NSMutableAttributedString(string: stepLabelContent, attributes:
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0 * aspectRatioFontFactor, weight: .thin)])
        let boldFontAttribute = [NSAttributedString.Key.font:
            UIFont.systemFont(ofSize: 24.0 * aspectRatioFontFactor, weight: .bold)]
        attributedString.addAttributes(boldFontAttribute, range: NSMakeRange(0, step.number.romanNumeral.count))

        stepLabel.attributedText = attributedString

        stepLabel.textAlignment = .center
        stepLabel.numberOfLines = 0

        return stepLabel
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffset: CGFloat = 116
        lastContentOffset = scrollView.contentOffset.y

        imageGradientLayer.calculateLocation(offset: lastContentOffset, maxOffset: maxOffset)

        let currentStepFloat = (stepOffset * 0.93 + lastContentOffset) / stepOffset
        currentStep = min(
            Int(floor(currentStepFloat)),
            recipe.analyzedInstructions.first!.steps.count)

//        print(currentStepFloat)

        let currentStepFloatReminder = currentStepFloat.truncatingRemainder(dividingBy: 1)

        if (0.0...0.1).contains(currentStepFloatReminder) ||
            (0.9...1.0).contains(currentStepFloatReminder)
        {
            ingredientsScrollView.layer.opacity = 0
        } else if (0.1...0.29).contains(currentStepFloatReminder) ||
            (0.71...0.9).contains(currentStepFloatReminder)
        {
            ingredientsScrollView.layer.opacity = Float(currentStepFloatReminder > 0.5
                ? (0.9 - currentStepFloatReminder) * (100 / 19) : (currentStepFloatReminder - 0.1) * (100 / 19))
        } else {
            ingredientsScrollView.layer.opacity = 1
        }

//        print(ingredientsScrollView.layer.opacity)

        descriptionLabelConstraint!.constant = max(0, ceil(detailImageView.frame.height / 2 - lastContentOffset))

        fadeScrollView.gradientLayer.colors = [fadeScrollView.topOpacity,
                                               fadeScrollView.opaqueColor,
                                               fadeScrollView.opaqueColor,
                                               fadeScrollView.bottomOpacity]
    }
}

// swiftlint:enable type_body_length
