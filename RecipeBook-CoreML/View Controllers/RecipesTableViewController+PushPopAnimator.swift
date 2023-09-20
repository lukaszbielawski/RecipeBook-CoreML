//
//  RecipesTableViewController+PushPopAnimation.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 20/09/2023.
//

import Foundation
import UIKit

extension RecipesTableViewController {
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

            let rightTransform = CGAffineTransform(translationX:
                transitionContext.containerView.bounds.size.width, y: 0)
            let leftTransform = CGAffineTransform(translationX:
                -transitionContext.containerView.bounds.size.width, y: 0)

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
}
