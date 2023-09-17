//
//  FilterView.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 16/09/2023.
//

import UIKit

final class FilterView: UIView {
    var segmentedControlsDictionary: [UISegmentedControl: [String]] = [:]

    init() {
        super.init(frame: .zero)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .primaryColor
        self.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        self.layer.cornerRadius = 16.0
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 7.0
        self.layer.shadowOpacity = 1
        self.layer.shadowColor = UIColor.accentColor.cgColor

        let veganSegmentedControl = UISegmentedControl(items:
            ["None", UIImage(systemName: "leaf")!, UIImage(systemName: "leaf.fill")!])
        let dishSegmentedControl = UISegmentedControl(items:
            ["None", "Breakfast", "Dinner", "Dessert"])
        let intolerancesSegmentedControl = UISegmentedControl(items:
            ["None", "No gluten", "No dairy"])

        self.segmentedControlsDictionary[veganSegmentedControl] = ["", "vegetarian", "vegan"]
        self.segmentedControlsDictionary[dishSegmentedControl] = ["", "breakfast", "main+course", "dessert"]
        self.segmentedControlsDictionary[intolerancesSegmentedControl] = ["", "gluten+free", "dairy+free"]

        for control in self.segmentedControlsDictionary.keys {
            control.translatesAutoresizingMaskIntoConstraints = false
            control.selectedSegmentIndex = 0
            self.addSubview(control)

            NSLayoutConstraint.activate([
                control.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                control.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            ])
        }

        NSLayoutConstraint.activate([
            veganSegmentedControl.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            dishSegmentedControl.topAnchor.constraint(equalTo: veganSegmentedControl.bottomAnchor, constant: 16),
            intolerancesSegmentedControl.topAnchor.constraint(equalTo: dishSegmentedControl.bottomAnchor, constant: 16),
            intolerancesSegmentedControl.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
        ])
    }

    func getFilters() -> [String] {
        var queryStrings: [String] = []
        for (key, value) in self.segmentedControlsDictionary {
            queryStrings.append(value[key.selectedSegmentIndex])
        }
        return queryStrings
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
