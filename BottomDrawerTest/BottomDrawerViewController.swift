//
//  BottomDrawerViewController.swift
//  BottomDrawerTest
//
//  Created by Jeff Grossman on 7/28/18.
//  Copyright © 2018 Jeff Grossman. All rights reserved.
//

import UIKit

class BottomDrawerViewController: UIViewController, UIViewControllerTransitioningDelegate {

    let panGestureRecognizer = UIPanGestureRecognizer()
    var interactionController: UIPercentDrivenInteractiveTransition?

    let tapGestureRecognizer = UITapGestureRecognizer()

    var leadingConstraint: NSLayoutConstraint?
    var trailingConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?

    init() {
        super.init(nibName: nil, bundle: nil)

        panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))

        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yellow

        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.text = [
            "Tap on dimming view or swipe down on drawer to close.",
            "Tapping on bottom drawer to close is intentionally not implemented.",
        ].joined(separator: "\n\n")
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: label.trailingAnchor, multiplier: 2),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            view.heightAnchor.constraint(equalToConstant: 600),
        ])

        view.addGestureRecognizer(panGestureRecognizer)

        tapGestureRecognizer.addTarget(self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    func addToParent(_ parent: UIViewController) {
        parent.addChild(self)
        parent.view.addSubview(self.view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.view.leadingAnchor.constraint(equalTo: parent.view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            parent.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 8),
            self.view.topAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: -200),
        ])
        self.didMove(toParent: parent)
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
        let pct = max(0, min(1, sign * translation.y / (view.bounds.height - 200)))

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
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()

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

                self.addToParent(parent)
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

            self.addToParent(presenting)
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
