//
//  TransitioningObject.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 20/09/2023.
//

import Foundation
import UIKit

extension TabBarViewController {
    class TransitioningObject: NSObject, UIViewControllerAnimatedTransitioning {
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let fromView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            let toView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!

            transitionContext.containerView.addSubview(fromView)
            transitionContext.containerView.addSubview(toView)

            UIView.transition(
                from: fromView,
                to: toView,
                duration: transitionDuration(using: transitionContext),
                options: UIView.AnimationOptions.transitionCrossDissolve)
            { _ in
                transitionContext.completeTransition(true)
            }
        }

        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.25
        }
    }
}
