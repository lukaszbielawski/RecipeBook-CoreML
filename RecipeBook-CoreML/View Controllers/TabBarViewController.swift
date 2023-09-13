//
//  TabBarViewController.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import UIKit

final class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let firstTab = RecipesTableViewController()
        let firstTabBarItem = UITabBarItem(title: "Recipes", image: UIImage(systemName: "book.fill"),
                                           selectedImage: UIImage(systemName: "book.fill"))
        firstTab.tabBarItem = firstTabBarItem

        let secondTab = ScannerViewController()
        let secondTabBarItem = UITabBarItem(title: "Scanner",
                                            image: UIImage(systemName: "dot.viewfinder"),
                                            selectedImage: UIImage(systemName: "dot.viewfinder"))
        secondTab.tabBarItem = secondTabBarItem

        self.viewControllers = [firstTab, secondTab]
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print(viewController.title!)
    }
}
