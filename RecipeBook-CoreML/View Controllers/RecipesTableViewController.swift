//
//  TableViewController.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import Combine
import UIKit

final class RecipesTableViewController: UIViewController, UITableViewDelegate {
    var tableView = UITableView()
    var viewModel = RecipesViewModel()

    var searchViewTopConstraint: NSLayoutConstraint?
    var tableViewTopConstraint: NSLayoutConstraint?
    var filterViewTopConstraint: NSLayoutConstraint?

    var finishedLoadingDataSubscribtion: AnyCancellable?

    var isSearchButtonActive = true {
        didSet {
            if !isSearchButtonActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.isSearchButtonActive = true
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        setup()
        setupSubscribtion()
        viewModel.loadRecipes()
    }

    lazy var filterView: FilterView = {
        let filterView = FilterView()
        return filterView
    }()

    lazy var searchView: SearchView = {
        let searchView = SearchView()

        searchView.searchTextField.delegate = self

        searchView.showFiltersIconView.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(showFiltersImageViewDidTapped)))

        searchView.searchButton.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(searchButtonDidTapped)))

        return searchView
    }()

    lazy var maskFilterView: UIView = {
        let maskFilterView = UIView()
        maskFilterView.translatesAutoresizingMaskIntoConstraints = false
        maskFilterView.backgroundColor = .backgroundColor
        return maskFilterView
    }()

    @objc private func showFiltersImageViewDidTapped(sender: UITapGestureRecognizer) {
        searchView.showFiltersIconView.isExtended.toggle()
        animateFilterView()
    }

    @objc private func searchButtonDidTapped() {
        guard isSearchButtonActive else { return }
        isSearchButtonActive = false

        view.endEditing(true)

        var queryItems: [String] = filterView.getFilters()
        queryItems.append(searchView.searchTextField.getTextFieldValue())

        viewModel.search(withQueryItems: queryItems)
        searchView.showFiltersIconView.isExtended = false
        animateFilterView()
    }

    func performScannerSearch(ingredients: [String]) {
        let mappedIngredients = ingredients.map { $0.replacingOccurrences(of: " ", with: "+") }

        viewModel.search(withQueryItems: [], scannerIngredients: mappedIngredients)
    }

    func setup() {
        view.backgroundColor = .backgroundColor
        tableView.backgroundColor = .backgroundColor

        view.addSubview(tableView)
        view.addSubview(filterView)
        view.addSubview(maskFilterView)
        view.addSubview(searchView)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            filterView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 16),
            filterView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -16),

            maskFilterView.topAnchor.constraint(equalTo: view.topAnchor),
            maskFilterView.bottomAnchor.constraint(equalTo: tableView.topAnchor),
            maskFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            maskFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),

            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchView.heightAnchor.constraint(equalToConstant: 50),
        ])
        filterViewTopConstraint = filterView.topAnchor.constraint(
            equalTo: searchView.bottomAnchor, constant: -view.layer.bounds.height / 2)

        filterViewTopConstraint?.isActive = true

        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: searchView.bottomAnchor)
        tableViewTopConstraint?.isActive = true

        searchViewTopConstraint = searchView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        searchViewTopConstraint?.isActive = true

        tableView.register(RecipesTableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func setupSubscribtion() {
        finishedLoadingDataSubscribtion =
            viewModel
                .dataLoadingFinishedPublisher
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    self.tableView.reloadData()
                }
    }

    private func animateFilterView() {
        guard let filterViewTopConstraint = filterViewTopConstraint else { return }

        UIView.animate(withDuration: 1.0) {
            filterViewTopConstraint.constant =
                self.searchView.showFiltersIconView.isExtended ? 16 : -self.view.layer.bounds.height / 2
            self.view.layoutIfNeeded()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.title = "Explore recipes"
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchViewTopConstraint?.constant = max(-scrollView.contentOffset.y, 0) + 8
        tableViewTopConstraint?.constant = min(scrollView.contentOffset.y, 0)
    }
}

extension RecipesTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("")
        searchButtonDidTapped()
        return true
    }
}

extension RecipesTableViewController: UITableViewDataSource {
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
        guard let cell = tableView.cellForRow(at: indexPath) as? RecipesTableViewCell else {
            return
        }
        guard let image = cell.recipeImageView.image else { return }

        let detailsVc = DetailsViewController(recipe: viewModel.recipes[indexPath.row], image: image)
        navigationController?.modalPresentationStyle = .formSheet
        navigationController?.pushViewController(detailsVc, animated: true)
    }
}

extension RecipesTableViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return PushPopAnimator(operation: operation)
    }
}
