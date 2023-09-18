//
//  SearchTextField.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 16/09/2023.
//

import UIKit

final class SearchTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .primaryColor
        self.autocorrectionType = .no
        self.autocapitalizationType = .none

        self.layer.cornerRadius = 16.0

        let imageSymbolView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageSymbolView.translatesAutoresizingMaskIntoConstraints = false

        guard let size = imageSymbolView.image?.size else { return }

        let imageSymbolContainer = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        imageSymbolContainer.translatesAutoresizingMaskIntoConstraints = false
        imageSymbolContainer.addSubview(imageSymbolView)

        NSLayoutConstraint.activate([
            imageSymbolView.topAnchor.constraint(equalTo: imageSymbolContainer.topAnchor, constant: 0),
            imageSymbolView.bottomAnchor.constraint(equalTo: imageSymbolContainer.bottomAnchor, constant: 0),
            imageSymbolView.leadingAnchor.constraint(equalTo: imageSymbolContainer.leadingAnchor, constant: 8),
            imageSymbolView.trailingAnchor.constraint(equalTo: imageSymbolContainer.trailingAnchor, constant: -4),
        ])

        self.leftView = imageSymbolContainer
        self.leftViewMode = .always

        self.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        self.rightViewMode = .always
    }

    func getTextFieldValue() -> String {
        return text ?? ""
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
