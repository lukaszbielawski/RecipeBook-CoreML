//
//  TableViewController.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 11/09/2023.
//

import UIKit

final class RecipesTableViewController: UIViewController, UITableViewDelegate {
    var tableView = UITableView()
    var viewModel = RecipesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipes"
        navigationController?.delegate = self
        setup()
        viewModel.loadRecipes()
    }

    func setup() {
        navigationController?.navigationBar.topItem?.title = "Explore Recipes"
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.titleTextAttributes =
//            [NSAttributedString.Key.foregroundColor: UIColor.accentColor]
//        navigationController?.navigationBar.largeTitleTextAttributes =
//            [NSAttributedString.Key.foregroundColor: UIColor.accentColor]
        view.backgroundColor = .backgroundColor
        tableView.backgroundColor = .backgroundColor
        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

        ])
     
        tableView.register(RecipesTableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

class PushPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let operation: UINavigationController.Operation

    init(operation: UINavigationController.Operation) {
        self.operation = operation
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let from = transitionContext.viewController(forKey: .from)!
        let target = transitionContext.viewController(forKey: .to)!

        let rightTransform = CGAffineTransform(translationX: transitionContext.containerView.bounds.size.width, y: 0)
        let leftTransform = CGAffineTransform(translationX: -transitionContext.containerView.bounds.size.width, y: 0)

        if operation == .push {
            target.view.transform = rightTransform
            transitionContext.containerView.addSubview(target.view)
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0.0,
                           animations: {
                               from.view.transform = leftTransform
                               target.view.transform = .identity
                           }, completion: { _ in
                               from.view.transform = .identity
                               transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                           })
        } else if operation == .pop {
            target.view.transform = leftTransform
            transitionContext.containerView.insertSubview(target.view, belowSubview: from.view)
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0.0,
                           animations: {
                               target.view.transform = .identity
                               from.view.transform = rightTransform
                           }, completion: { _ in
                               from.view.transform = .identity
                               transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                           })
        }
    }
}
