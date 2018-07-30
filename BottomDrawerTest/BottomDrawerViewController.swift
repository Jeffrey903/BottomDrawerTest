//
//  BottomDrawerViewController.swift
//  BottomDrawerTest
//
//  Created by Jeff Grossman on 7/28/18.
//  Copyright © 2018 Jeff Grossman. All rights reserved.
//

import UIKit

class BottomDrawerViewController: UIViewController, UIViewControllerTransitioningDelegate {

    enum Visibility {
        case `default`
        case expanded
        case minimized
    }

    weak var presenting: UIViewController?
    let child: UIViewController & BottomDrawer

    private(set) var visibility: Visibility

    let panGestureRecognizer = UIPanGestureRecognizer()
    var presentingAnimator: BottomDrawerPresentingAnimator?
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
        self.visibility = .default

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

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 2)

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

    func setVisibility(_ visibility: Visibility, animated: Bool) {
        setVisibility(visibility, animated: animated, isInteractive: false)
    }

    private func setVisibility(_ visibility: Visibility, animated: Bool, isInteractive: Bool) {
        let oldVisibility = self.visibility
        guard oldVisibility != visibility else {
            return
        }

        self.visibility = visibility

        switch (oldVisibility, visibility) {
        case (_, .expanded):
            expand(animated: animated, isInteractive: isInteractive, oldVisibility: oldVisibility)
        case (.expanded, _):
            collapse(animated: animated, isInteractive: isInteractive)
        default:
            guard let presenting = presenting else {
                return
            }

            self.bottomConstraint?.isActive = false

            let newBottomConstraint = bottomConstraint(forVisibility: visibility, containerView: presenting.view)
            newBottomConstraint.isActive = true
            self.bottomConstraint = newBottomConstraint

            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    presenting.view.layoutIfNeeded()
                })
            }
        }
    }

    func bottomConstraint(forVisibility visibility: Visibility, containerView: UIView) -> NSLayoutConstraint {
        switch visibility {
        case .default:
            return child.bottomLayoutAnchorForDefaultVisibility.constraint(equalTo: containerView.bottomAnchor)
        case .minimized:
            return view.topAnchor.constraint(equalTo: containerView.bottomAnchor)
        case .expanded:
            return view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        }
    }

    private func setupViewControllerContainment() {
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
        let bottomConstraint = self.bottomConstraint(forVisibility: visibility, containerView: presenting.view)

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
        guard gestureRecognizer.state == .ended else {
            return
        }

        setVisibility(.expanded, animated: true, isInteractive: false)
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.state != .began else {
            if self.visibility == .expanded {
                self.setVisibility(.default, animated: true, isInteractive: true)
            } else {
                self.setVisibility(.expanded, animated: true, isInteractive: true)
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

    private func expand(animated: Bool, isInteractive: Bool, oldVisibility: Visibility) {
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

        self.presentingAnimator = BottomDrawerPresentingAnimator(oldVisibility: oldVisibility)

        if isInteractive {
            self.interactionController = UIPercentDrivenInteractiveTransition()
        }

        // If I immediately present the VC, the console prints "Unbalanced calls to begin/end appearance transitions for _____" and I can sometimes see the bottom drawer flicker.
        // So perform the presentation asynchronously after a small delay, which stops the warning from printing. Using `DispatchQueue.main.async` (even twiced nested), was not sufficient.
        // Using a snapshot view fixes the flicker.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            // Present VC
            parent.present(self, animated: animated) {
                // If presentation is cancelled, re-add VC to parent
                guard self.parent == nil && self.presentingViewController == nil else {
                    return
                }

                self.visibility = .default
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

    private func collapse(animated: Bool, isInteractive: Bool) {
        guard let presenting = self.presentingViewController else {
            return
        }

        if isInteractive {
            interactionController = UIPercentDrivenInteractiveTransition()
        }

        presenting.dismiss(animated: animated) {
            // If dismissal is successful, re-add VC to parent
            guard self.parent == nil && self.presentingViewController == nil else {
                self.visibility = .expanded
                return
            }

            self.setupViewControllerContainment()
        }
    }

    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.presentingAnimator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomDrawerDismissingAnimator(newVisibility: visibility)
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
