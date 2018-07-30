//
//  BottomDrawerDismissingAnimator.swift
//  BottomDrawerTest
//
//  Created by Jeff Grossman on 7/28/18.
//  Copyright © 2018 Jeff Grossman. All rights reserved.
//

import UIKit

class BottomDrawerDismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let newVisibility: BottomDrawerViewController.Visibility

    init(newVisibility: BottomDrawerViewController.Visibility) {
        self.newVisibility = newVisibility
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        let bottomDrawer = transitionContext.viewController(forKey: .from) as! BottomDrawerViewController
        bottomDrawer.leadingConstraint?.constant = 8
        bottomDrawer.trailingConstraint?.constant = 8

        let oldBottomConstraint = bottomDrawer.bottomConstraint
        let newBottomConstraint = bottomDrawer.bottomConstraint(forVisibility: newVisibility, containerView: containerView)
        bottomDrawer.bottomConstraint = newBottomConstraint

        oldBottomConstraint?.isActive = false
        newBottomConstraint.isActive = true

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
            containerView.layoutIfNeeded()
        }) { _ in
            if transitionContext.transitionWasCancelled {
                bottomDrawer.leadingConstraint?.constant = 0
                bottomDrawer.trailingConstraint?.constant = 0
                bottomDrawer.bottomConstraint = oldBottomConstraint
                newBottomConstraint.isActive = false
                oldBottomConstraint?.isActive = true
            }

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

}
