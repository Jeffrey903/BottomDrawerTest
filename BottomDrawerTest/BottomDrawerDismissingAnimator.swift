//
//  BottomDrawerDismissingAnimator.swift
//  BottomDrawerTest
//
//  Created by Jeff Grossman on 7/28/18.
//  Copyright © 2018 Jeff Grossman. All rights reserved.
//

import UIKit

class BottomDrawerDismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        let bottomDrawer = transitionContext.viewController(forKey: .from) as! BottomDrawerViewController
        bottomDrawer.leadingConstraint?.constant = 8
        bottomDrawer.trailingConstraint?.constant = 8
        bottomDrawer.bottomConstraint?.constant = bottomDrawer.child.expandedHeight() - bottomDrawer.child.collapsedHeight()

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
            containerView.layoutIfNeeded()
        }) { _ in
            if transitionContext.transitionWasCancelled {
                bottomDrawer.leadingConstraint?.constant = 0
                bottomDrawer.trailingConstraint?.constant = 0
                bottomDrawer.bottomConstraint?.constant = 0
            }

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

}
