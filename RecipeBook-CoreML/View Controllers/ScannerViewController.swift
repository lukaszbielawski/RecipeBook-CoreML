//
//  ScannerViewController.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import UIKit

final class ScannerViewController: UIViewController, Taggable {
    var tag: TabType = .scanner

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .primaryColor
        self.title = "Scanner"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.title = self.tag.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
