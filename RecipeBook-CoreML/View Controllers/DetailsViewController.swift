//
//  DetailsViewController.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 13/09/2023.
//

import UIKit

final class DetailsViewController: UIViewController {
    var recipe: Recipe
    var image: UIImage
    private var lastContentOffset: CGFloat = 0
    private var descriptionLabelConstraint: NSLayoutConstraint?
    private lazy var stepOffset = (view.layer.bounds.height * 0.5)
    private var stepViewsArray: [UIView] = []

    private var currentStep: Int = 0 {
        didSet {
            if currentStep != oldValue {
                print("set \(currentStep)")
                setStep(step: currentStep)
            }
        }
    }

    private var ingredientsImages: [(Int, UIImage)] = []

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

    //    lazy var descriptionView: UIView = {
    //        let descriptionView = UIView()
    //        descriptionView.translatesAutoresizingMaskIntoConstraints = false
    //        descriptionView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    //        scrollStackViewContainer.addArrangedSubview(descriptionView)
    //        NSLayoutConstraint.activate([
    //            descriptionView.heightAnchor.constraint(equalToConstant: 300),
    //        ])
    //        return descriptionView
    //    }()

    lazy var ingredientsScrollView: UIScrollView = {
        let ingredientsScrollView = UIScrollView()
        ingredientsScrollView.translatesAutoresizingMaskIntoConstraints = false
        ingredientsScrollView.showsHorizontalScrollIndicator = false
        //        ingredientsScrollView.transform = CGAffineTransform(rotationAngle: .pi);
        //        ingredientsScrollView.backgroundColor = UIColor.accentColor
        ingredientsScrollView.layer.opacity = 0.0

        return ingredientsScrollView
    }()

    lazy var ingredientsStackView: UIStackView = {
        let ingredientsStackView = UIStackView()
        ingredientsStackView.spacing = 8
        ingredientsStackView.translatesAutoresizingMaskIntoConstraints = false
        ingredientsStackView.backgroundColor = UIColor.clear
        ingredientsStackView.axis = .horizontal

        return ingredientsStackView
    }()

    lazy var descriptionLabel: UILabel = {
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
        setupView()
        setupConstraints()
        Task {
            await loadStepImages()
        }
        setupInstructions()
    }

    func setupView() {
        view.backgroundColor = .backgroundColor

        //        generateStepLabels()
    }

    func setupConstraints() {
        view.addSubview(detailsTitleLabel)
        view.addSubview(fadeScrollView)
        view.addSubview(detailImageView)
        view.addSubview(descriptionLabel)
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
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
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
            try await withThrowingTaskGroup(of: (Int, UIImage).self) { group in
                for step in self.recipe.analyzedInstructions.first!.steps {
                    for ingredient in step.ingredients {
                        group.addTask {
                            try (step.number, await ImageDownloader.shared.downloadImage(
                                from: "https://spoonacular.com/cdn/ingredients_100x100/\(ingredient.image)",
                                crop: false))
                        }
                    }
                }
                for try await (number, image) in group {
                    self.ingredientsImages.append((number, image))
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
                descriptionLabel.bottomAnchor.constraint(equalTo: fadeScrollView.topAnchor,
                                                         constant: detailImageView.frame.height / 2)
            descriptionLabelConstraint?.isActive = true
        }

        imageGradientLayer.frame = detailImageView.bounds
        detailImageView.layer.mask = imageGradientLayer
    }

    private func setStep(step: Int) {
        guard step > -1 else { return }
        ingredientsStackView.removeAllArrangedSubviews()
        for (index, ingredientImage) in ingredientsImages.filter({ $0.0 == step }) {
            ingredientsStackView.addArrangedSubview(makeIngredientImageView(image: ingredientImage))
        }
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
            ingredientImageView.heightAnchor.constraint(equalToConstant: ingredientsScrollView.layer.bounds.height),
            ingredientImageView.widthAnchor.constraint(equalToConstant: ingredientsScrollView.layer.bounds.height),
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
            stepLabel.topAnchor.constraint(equalTo: stepView.topAnchor, constant: 8),
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

            innerLabel.text = "Next step"
            innerLabel.font = UIFont.systemFont(ofSize: 18)
            innerLabel.paddingTop = 4.0
            innerLabel.paddingBottom = 4.0
            innerLabel.paddingLeft = 8.0
            innerLabel.paddingRight = 8.0

            innerLabel.layer.cornerRadius = 12.0
            innerLabel.layer.masksToBounds = true
//            label.
            innerLabel.backgroundColor = .accentColor
            innerLabel.textColor = .white
//            nextStepButton.backgroundColor = .accentColor
            nextStepButton.layer.opacity = 1.0
//            nextStepButton.setTitle("Next", for: .normal)
            nextStepButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)

            stepView.addSubview(nextStepButton)
            NSLayoutConstraint.activate([
                nextStepButton.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 10),
                nextStepButton.centerXAnchor.constraint(equalTo: stepLabel.centerXAnchor),
                innerLabel.centerYAnchor.constraint(equalTo: nextStepButton.centerYAnchor),
                innerLabel.centerXAnchor.constraint(equalTo: nextStepButton.centerXAnchor),
            ])
        } else {
            // TODO: nowa funkcjonalnosc po ostatnim przycisku
        }

        return stepView
    }

    @objc private func nextButtonAction() {
        fadeScrollView.setContentOffset(
            CGPoint(x: 0.0, y: stepViewsArray[currentStep].layer.position.y - 72),
            animated: true)
    }

    private func makeStepLabel(step: Step) -> UILabel {
        let stepLabel = UILabel()
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        stepLabel.text = "\(step.number). \(step.step)"
        stepLabel.numberOfLines = 0
        stepLabel.font = UIFont.systemFont(ofSize: 27.0, weight: .thin)
        stepLabel.adjustsFontSizeToFitWidth = true

        return stepLabel
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffset: CGFloat = 150
        let didScrolledUp = lastContentOffset - scrollView.contentOffset.y > 0

        lastContentOffset = scrollView.contentOffset.y
        imageGradientLayer.calculateLocation(offset: lastContentOffset, maxOffset: maxOffset)

        let opacity = Float(max(lastContentOffset > maxOffset * 0.75 ?
                (lastContentOffset - maxOffset * 0.75) / (maxOffset * 0.2) :
                (lastContentOffset - maxOffset * 0.75) / (maxOffset * 0.75),
            0.0))

        ingredientsScrollView.layer.opacity = opacity

//        if didScrolledUp && opacity < 0.75 && ingredientsScrollView.layer.opacity >= 1.0 {
//            UIView.animate(withDuration: 0.5) {
//                self.ingredientsScrollView.layer.opacity = 0
//            }
//        } else if !didScrolledUp && opacity > 0.25 && ingredientsScrollView.layer.opacity == 0.0 {
//            UIView.animate(withDuration: 0.5) {
//                self.ingredientsScrollView.layer.opacity = 1
//            }
//        }
        currentStep = min(Int(floor((stepOffset * 0.75 + lastContentOffset) / stepOffset)),
                          recipe.analyzedInstructions.first!.steps.count)

        descriptionLabelConstraint!.constant = max(0, ceil(detailImageView.frame.height / 2 - lastContentOffset))

        fadeScrollView.gradientLayer.colors = [fadeScrollView.topOpacity,
                                               fadeScrollView.opaqueColor,
                                               fadeScrollView.opaqueColor,
                                               fadeScrollView.bottomOpacity]
    }
}
