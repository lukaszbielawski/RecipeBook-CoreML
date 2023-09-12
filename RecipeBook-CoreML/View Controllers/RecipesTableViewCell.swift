//
//  TableViewCell.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import UIKit

class RecipesTableViewCell: UITableViewCell {
    var recipeData: Recipe?

    lazy var recipeImageView = {
        let recipeImageView = UIImageView()
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        recipeImageView.backgroundColor = .secondaryColor
        recipeImageView.contentMode = .scaleAspectFill
//        recipeImageView.image = UIImage(named: "AppIcon")

        recipeImageView.layer.cornerRadius = 16
        recipeImageView.layer.masksToBounds = true

        return recipeImageView
    }()

    lazy var recipeAttributesStackView = {
        let recipeAttributesStackView = UIStackView()
        recipeAttributesStackView.translatesAutoresizingMaskIntoConstraints = false
        recipeAttributesStackView.axis = .horizontal
        recipeAttributesStackView.spacing = 8.0
        return recipeAttributesStackView
    }()

    var recipeTitleLabel = {
        let recipeTitleLabel = UILabel()
        recipeTitleLabel.textColor = .secondaryColor
        recipeTitleLabel.numberOfLines = 2
        recipeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeTitleLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        return recipeTitleLabel
    }()

    var recipeTimeLabel = {
        let recipeTimeLabel = PaddingLabel()

        recipeTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeTimeLabel.textColor = .white
        recipeTimeLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        recipeTimeLabel.backgroundColor = .systemBlue
        recipeTimeLabel.sizeToFit()
        recipeTimeLabel.layer.cornerRadius = 8.0
        recipeTimeLabel.layer.masksToBounds = true
        recipeTimeLabel.paddingLeft = 6.0
        recipeTimeLabel.paddingRight = 6.0
        recipeTimeLabel.paddingTop = 4.0
        recipeTimeLabel.paddingBottom = 4.0

        return recipeTimeLabel
    }()

    var veganOrVegetarianLabel = {
        let veganOrVegetarianLabel = PaddingLabel()

        veganOrVegetarianLabel.translatesAutoresizingMaskIntoConstraints = false
        veganOrVegetarianLabel.textColor = .white
        veganOrVegetarianLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        veganOrVegetarianLabel.backgroundColor = .systemGreen
        veganOrVegetarianLabel.sizeToFit()
        veganOrVegetarianLabel.layer.cornerRadius = 8.0
        veganOrVegetarianLabel.layer.masksToBounds = true
        veganOrVegetarianLabel.attributedText = "Vegetarian".attachIconToString(systemName: "leaf", color: .white)
        veganOrVegetarianLabel.isHidden = true
        veganOrVegetarianLabel.paddingLeft = 6.0
        veganOrVegetarianLabel.paddingRight = 6.0
        veganOrVegetarianLabel.paddingTop = 4.0
        veganOrVegetarianLabel.paddingBottom = 4.0

        return veganOrVegetarianLabel
    }()

    var healthScoreLabel = {
        let healthScoreLabel = ProgressLabel()

        healthScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        healthScoreLabel.textColor = .white
        healthScoreLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        healthScoreLabel.textColor = UIColor.white
        healthScoreLabel.sizeToFit()
        healthScoreLabel.layer.cornerRadius = 8.0
        healthScoreLabel.layer.masksToBounds = true
        healthScoreLabel.attributedText = "Health score".attachIconToString(systemName: "heart", color: .white)

        healthScoreLabel.layer.borderColor = UIColor.raspberryColor.cgColor
        healthScoreLabel.layer.borderWidth = 1
        healthScoreLabel.paddingLeft = 4.0
        healthScoreLabel.paddingRight = 0.0
        healthScoreLabel.paddingTop = 4.0
        healthScoreLabel.paddingBottom = 4.0

        return healthScoreLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupBackgroundView()
        addSubviews()
        setupConstraints()
    }

    private func setupBackgroundView() {
        backgroundView = UIView()

        guard let backgroundView = backgroundView else { return }

        contentView.backgroundColor = UIColor.backgroundColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor.primaryColor
        backgroundView.layer.cornerRadius = 16
    }

    private func addSubviews() {
        guard let backgroundView = backgroundView else { return }

        contentView.addSubview(backgroundView)
        backgroundView.addSubview(recipeImageView)
        backgroundView.addSubview(recipeTitleLabel)
        backgroundView.addSubview(recipeAttributesStackView)
        backgroundView.addSubview(healthScoreLabel)
        recipeAttributesStackView.addArrangedSubview(recipeTimeLabel)
        recipeAttributesStackView.addArrangedSubview(veganOrVegetarianLabel)
    }

    private func setupConstraints() {
        guard let backgroundView = backgroundView else { return }

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
//
            recipeImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            recipeImageView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            recipeImageView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            recipeImageView.widthAnchor.constraint(equalToConstant: CGFloat(Int(UIScreen.main.bounds.height * 0.20))),
            recipeImageView.heightAnchor.constraint(equalToConstant: CGFloat(Int(UIScreen.main.bounds.height * 0.20))),
//
            recipeTitleLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 8),
            recipeTitleLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 16),
            recipeTitleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8),
//
            recipeAttributesStackView.topAnchor.constraint(equalTo: recipeTitleLabel.bottomAnchor, constant: 4),
//            recipeAttributesStackView.bottomAnchor.constraint(equalTo: recipeTitleLabel.bottomAnchor, constant: 4),
            recipeAttributesStackView.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 16),
//
//
            healthScoreLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 16),
            healthScoreLabel.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -16),
            healthScoreLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16)
        ])
    }

    func loadData() {
        guard let recipeData = recipeData else { return }

        if let imageUrl = recipeData.image {
            Task {
                do {
                    recipeImageView.image = try await ImageDownloader.shared.downloadImage(from: imageUrl)
                } catch {
                    print(error)
                }
            }
        }

        recipeTitleLabel.text = recipeData.title

        recipeTimeLabel.attributedText = "\(recipeData.readyInMinutes)'"
            .attachIconToString(systemName: "clock.fill", color: .white)

        if recipeData.vegan {
            veganOrVegetarianLabel.attributedText = "Vegan".attachIconToString(systemName: "leaf.fill", color: .white)
            veganOrVegetarianLabel.backgroundColor = .systemGreen
            veganOrVegetarianLabel.isHidden = false
        } else if recipeData.vegetarian {
            veganOrVegetarianLabel.attributedText = "Vegetarian".attachIconToString(systemName: "leaf", color: .white)
            veganOrVegetarianLabel.backgroundColor = .mintColor
            veganOrVegetarianLabel.isHidden = false
        } else {
            veganOrVegetarianLabel.isHidden = true
        }

        healthScoreLabel.progress = Float(recipeData.healthScore)

//        recipeInstructionsLabel.text =
//            "Ingredients: \n• \(recipeData.extendedIngredients.map { $0.name }.joined(separator: "\n• "))"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
