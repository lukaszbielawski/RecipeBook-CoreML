//
//  ShowFiltersImageView.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 16/09/2023.
//

import UIKit

class ShowFiltersImageView: UIImageView {
    var isExtended: Bool = false {
        didSet {
            if self.isExtended {
                self.image = UIImage(systemName: "chevron.up")
            } else {
                self.image = UIImage(systemName: "chevron.down")
            }
        }
    }

    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.image = UIImage(systemName: "chevron.down")
        self.isUserInteractionEnabled = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
