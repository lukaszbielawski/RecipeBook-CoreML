//
//  SearchView.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 17/09/2023.
//

import Foundation
import UIKit

class SearchView: UIView {
    let searchTextField = SearchTextField()
    let searchButton = SearchButton()
    let showFiltersIconView = ShowFiltersImageView()

    override init(frame: CGRect) {
        super.init(frame: .zero)

        self.translatesAutoresizingMaskIntoConstraints = false

        addSubview(searchButton)
        addSubview(searchTextField)
        addSubview(showFiltersIconView)

        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            searchTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            searchTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -8),

            searchButton.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            searchButton.trailingAnchor.constraint(equalTo: showFiltersIconView.leadingAnchor, constant: -8),

            showFiltersIconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            showFiltersIconView.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
