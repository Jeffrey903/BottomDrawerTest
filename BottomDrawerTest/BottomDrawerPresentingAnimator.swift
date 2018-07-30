//
//  BottomDrawerPresentingAnimator.swift
//  BottomDrawerTest
//
//  Created by Jeff Grossman on 7/28/18.
//  Copyright © 2018 Jeff Grossman. All rights reserved.
//

import UIKit

class BottomDrawerPresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let oldVisibility: BottomDrawerViewController.Visibility

    init(oldVisibility: BottomDrawerViewController.Visibility) {
        self.oldVisibility = oldVisibility
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let bottomDrawer = transitionContext.viewController(forKey: .to) as! BottomDrawerViewController
        let containerView = transitionContext.containerView

        bottomDrawer.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bottomDrawer.view)

        let leadingConstraint = bottomDrawer.view.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 8)
        let trailingConstraint = containerView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: bottomDrawer.view.trailingAnchor, constant: 8)

        let oldBottomConstraint = bottomDrawer.bottomConstraint(forVisibility: oldVisibility, containerView: containerView)
        let newBottomConstraint = bottomDrawer.bottomConstraint(forVisibility: .expanded, containerView: containerView)

        bottomDrawer.leadingConstraint = leadingConstraint
        bottomDrawer.trailingConstraint = trailingConstraint
        bottomDrawer.bottomConstraint = newBottomConstraint

        NSLayoutConstraint.activate([
            leadingConstraint,
            trailingConstraint,
            oldBottomConstraint,
        ])

        containerView.layoutIfNeeded()

        leadingConstraint.constant = 0
        trailingConstraint.constant = 0
        oldBottomConstraint.isActive = false
        newBottomConstraint.isActive = true

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
            containerView.layoutIfNeeded()
        }) { _ in
            if transitionContext.transitionWasCancelled {
                leadingConstraint.constant = 8
                trailingConstraint.constant = 8
                bottomDrawer.bottomConstraint = oldBottomConstraint
                newBottomConstraint.isActive = false
                oldBottomConstraint.isActive = true
            }

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

}
