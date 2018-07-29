//
//  BottomDrawerViewController.swift
//  BottomDrawerTest
//
//  Created by Jeff Grossman on 7/28/18.
//  Copyright © 2018 Jeff Grossman. All rights reserved.
//

import UIKit

class BottomDrawerViewController: UIViewController, UIViewControllerTransitioningDelegate {

    weak var presenting: UIViewController?
    let child: UIViewController & BottomDrawer

    let panGestureRecognizer = UIPanGestureRecognizer()
    var interactionController: UIPercentDrivenInteractiveTransition?

    let tapGestureRecognizer = UITapGestureRecognizer()

    var cornerRadius: CGFloat = 0 {
        didSet {
            view.layer.cornerRadius = cornerRadius
            child.view.layer.cornerRadius = cornerRadius
        }
    }

    var leadingConstraint: NSLayoutConstraint?
    var trailingConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?

    init(withPresenting presenting: UIViewController, child: UIViewController & BottomDrawer) {
        self.presenting = presenting
        self.child = child

        super.init(nibName: nil, bundle: nil)

        setupViewControllerContainment()

        panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))

        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        child.view.layer.maskedCorners = view.layer.maskedCorners

        addChild(child)
        view.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        child.didMove(toParent: self)

        view.addGestureRecognizer(panGestureRecognizer)

        tapGestureRecognizer.addTarget(self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    func setupViewControllerContainment() {
        guard let presenting = presenting else {
            return
        }

        self.leadingConstraint?.isActive = false
        self.trailingConstraint?.isActive = false
        self.bottomConstraint?.isActive = false

        presenting.addChild(self)
        presenting.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        let leadingConstraint = view.leadingAnchor.constraint(equalTo: presenting.view.safeAreaLayoutGuide.leadingAnchor, constant: 8)
        let trailingConstraint = presenting.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8)
        let bottomConstraint = child.bottomLayoutAnchorForDefaultVisibility.constraint(equalTo: presenting.view.bottomAnchor)

        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, bottomConstraint])

        self.leadingConstraint = leadingConstraint
        self.trailingConstraint = trailingConstraint
        self.bottomConstraint = bottomConstraint

        self.didMove(toParent: presenting)
    }

    func removeViewControllerContainment() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()

        leadingConstraint = nil
        trailingConstraint = nil
        bottomConstraint = nil
    }

    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended, presentingViewController == nil else {
            return
        }

        expand(isInteractive: false)
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.state != .began else {
            if self.presentingViewController != nil {
                collapse(isInteractive: true)
            } else {
                expand(isInteractive: true)
            }
            return
        }

        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        let sign: CGFloat = isBeingDismissed ? 1 : -1
        let pct = max(0, min(1, sign * translation.y / (view.bounds.height - child.heightForDefaultVisibility)))

        switch gestureRecognizer.state {
        case .changed:
            interactionController?.update(pct)
        case .ended:
            let velocity = sign * gestureRecognizer.velocity(in: gestureRecognizer.view).y
            if pct > 0.5 || velocity > 100.0 {
                interactionController?.completionCurve = .easeInOut

                let speed = velocity / 500 * CGFloat(transitionCoordinator!.transitionDuration)
                interactionController?.completionSpeed = max(0.75, min(1.5, speed))
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        case .cancelled:
            interactionController?.cancel()
            interactionController = nil
        default:
            ()
        }
    }

    func expand(isInteractive: Bool) {
        guard let parent = parent else {
            return
        }

        // Create a short-lived snapshot view to workaround a visual flicker
        let window = UIApplication.shared.keyWindow
        let snapshotView = window?.snapshotView(afterScreenUpdates: false)
        if let snapshotView = snapshotView {
            window?.addSubview(snapshotView)
        }

        // If presentation is interactive, temporarily move the panGestureRecognizer to the parent so the gesture keeps working while this VC is quickly removed and re-presented
        if isInteractive {
            parent.view.addGestureRecognizer(panGestureRecognizer)
            view.removeGestureRecognizer(panGestureRecognizer)
        }

        // Remove VC
        removeViewControllerContainment()

        if isInteractive {
            self.interactionController = UIPercentDrivenInteractiveTransition()
        }

        // If I immediately present the VC, the console prints "Unbalanced calls to begin/end appearance transitions for _____" and I can sometimes see the bottom drawer flicker.
        // So perform the presentation asynchronously after a small delay, which stops the warning from printing. Using `DispatchQueue.main.async` (even twiced nested), was not sufficient.
        // Using a snapshot view fixes the flicker.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            // Present VC
            parent.present(self, animated: true) {
                // If presentation is cancelled, re-add VC to parent
                guard self.parent == nil && self.presentingViewController == nil else {
                    return
                }

                self.setupViewControllerContainment()
            }

            DispatchQueue.main.async {
                snapshotView?.removeFromSuperview()
            }

            // Put the panGestureRecognizer back on self.view
            if isInteractive {
                self.view.addGestureRecognizer(self.panGestureRecognizer)
                parent.view.removeGestureRecognizer(self.panGestureRecognizer)
            }
        }
    }

    func collapse(isInteractive: Bool) {
        guard let presenting = self.presentingViewController else {
            return
        }

        if isInteractive {
            interactionController = UIPercentDrivenInteractiveTransition()
        }

        presenting.dismiss(animated: true) {
            // If dismissal is successful, re-add VC to parent
            guard self.parent == nil && self.presentingViewController == nil else {
                return
            }

            self.setupViewControllerContainment()
        }
    }

    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomDrawerPresentingAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomDrawerDismissingAnimator()
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomDrawerPresentationController(presentedViewController: presented,
                                                  presenting: presenting)
    }

}
