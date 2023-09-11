//
//  TableViewCell.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import UIKit

class RecipesTableViewCell: UITableViewCell {
    var data: Recipe?

    lazy var recipeImageView = {
        let recipeImageView = UIImageView()
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        recipeImageView.backgroundColor = .secondaryColor
        recipeImageView.contentMode = .scaleAspectFit
        recipeImageView.image = UIImage(named: "AppIcon")

        recipeImageView.layer.cornerRadius = 16
        recipeImageView.layer.masksToBounds = true

        return recipeImageView
    }()

    var recipeTitleLabel = {
        let recipeTitleLabel = UILabel()
        recipeTitleLabel.textColor = .secondaryColor
        recipeTitleLabel.numberOfLines = 0
        recipeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeTitleLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        return recipeTitleLabel
    }()

    var recipeTimeLabel = {
        let recipeTimeLabel = UILabel()
        recipeTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeTimeLabel.textColor = .secondaryColor
        recipeTimeLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        recipeTimeLabel.layer.opacity = 0.7

        return recipeTimeLabel
    }()

    var recipeInstructionsLabel = {
        let recipeInstructionsLabel = UILabel()
        recipeInstructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeInstructionsLabel.textColor = .secondaryColor
        recipeInstructionsLabel.numberOfLines = 0
        return recipeInstructionsLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupBackgroundView()
        setupConstraints()
    }

    private func setupBackgroundView() {
        backgroundView = UIView()

        guard let backgroundView = backgroundView else { return }

        contentView.addSubview(backgroundView)
        contentView.backgroundColor = UIColor.backgroundColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.addSubview(recipeImageView)
        backgroundView.addSubview(recipeTitleLabel)
        backgroundView.addSubview(recipeTimeLabel)
        backgroundView.addSubview(recipeInstructionsLabel)

        
        backgroundView.backgroundColor = UIColor.primaryColor
        backgroundView.layer.cornerRadius = 16
    }

    private func setupConstraints() {
        guard let backgroundView = backgroundView else { return }

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
//
            recipeImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            recipeImageView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            recipeImageView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            recipeImageView.widthAnchor.constraint(equalToConstant: CGFloat(Int(UIScreen.main.bounds.height * 0.25))),
            recipeImageView.heightAnchor.constraint(equalToConstant: CGFloat(Int(UIScreen.main.bounds.height * 0.25))),
//
            recipeTitleLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 16),
            recipeTitleLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 8),
            recipeTitleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8),
//
            recipeTimeLabel.topAnchor.constraint(equalTo: recipeTitleLabel.bottomAnchor, constant: 4),
            recipeTimeLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 16),
            recipeTimeLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8),
//
//
            recipeInstructionsLabel.topAnchor.constraint(equalTo: recipeTimeLabel.bottomAnchor, constant: 4),
            recipeInstructionsLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 16),
            recipeInstructionsLabel.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -8),
            recipeInstructionsLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8)
        ])
    }

    func loadData() {
        guard let data = data else { return }
        recipeTitleLabel.text = data.title
        recipeTimeLabel.text = "\(data.readyInMinutes) min"
        recipeInstructionsLabel.text = "Ingredients: \n• \(data.extendedIngredients.map { $0.name }.joined(separator: "\n• "))"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
