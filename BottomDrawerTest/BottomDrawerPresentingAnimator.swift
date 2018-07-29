//
//  BottomDrawerPresentingAnimator.swift
//  BottomDrawerTest
//
//  Created by Jeff Grossman on 7/28/18.
//  Copyright © 2018 Jeff Grossman. All rights reserved.
//

import UIKit

class BottomDrawerPresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: .to)!
        let toView = toViewController.view!
        let containerView = transitionContext.containerView

        toView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(toView)

        let leadingConstraint = toView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 8)
        let trailingConstraint = containerView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 8)
        let bottomConstraint = toView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 400)

        if let bottomDrawer = toViewController as? BottomDrawerViewController {
            bottomDrawer.leadingConstraint = leadingConstraint
            bottomDrawer.trailingConstraint = trailingConstraint
            bottomDrawer.bottomConstraint = bottomConstraint
        }

        NSLayoutConstraint.activate([
            leadingConstraint,
            trailingConstraint,
            bottomConstraint,
        ])

        containerView.layoutIfNeeded()

        leadingConstraint.constant = 0
        trailingConstraint.constant = 0
        bottomConstraint.constant = 0

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
            containerView.layoutIfNeeded()
        }) { _ in
            if transitionContext.transitionWasCancelled {
                leadingConstraint.constant = 8
                trailingConstraint.constant = 8
                bottomConstraint.constant = 400
            }

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

}
