//
//  BottomDrawerPresentationController.swift
//  BottomDrawerTest
//
//  Created by Jeff Grossman on 7/29/18.
//  Copyright © 2018 Jeff Grossman. All rights reserved.
//

import UIKit

class BottomDrawerPresentationController: UIPresentationController {

    let dimmingView = UIView()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(handleDimmingViewTap(_:)))
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func handleDimmingViewTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else {
            return
        }

        if let bottomDrawer = presentedViewController as? BottomDrawerViewController {
            bottomDrawer.collapse(isInteractive: false)
        }
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dimmingView)

        NSLayoutConstraint.activate([
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        dimmingView.backgroundColor = .clear
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
            self?.presentedView?.layer.cornerRadius = 0
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.dimmingView.backgroundColor = .clear
            self?.presentedView?.layer.cornerRadius = 10
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }

}
