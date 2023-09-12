//
//  TableViewController.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import UIKit

class RecipesViewController: UIViewController, UITableViewDelegate {
    var tableView = UITableView()
    var viewModel = RecipesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipes"
        setup()
        viewModel.loadRecipes()
    }

    func setup() {
        navigationController?.navigationBar.topItem?.title = "Explore Recipes"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .backgroundColor

        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        tableView.register(RecipesTableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension RecipesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? RecipesTableViewCell
        else {
            return UITableViewCell()
        }

        cell.recipeData = viewModel.recipes[indexPath.row]
        cell.loadData()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(viewModel.recipes[indexPath.row].image ?? "null")
    }
}
