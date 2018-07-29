//
//  ContentsViewController.swift
//  BottomDrawerTest
//
//  Created by Jeff Grossman on 7/29/18.
//  Copyright © 2018 Jeff Grossman. All rights reserved.
//

import UIKit

class ContentsViewController: UIViewController, BottomDrawer {

    // Fake view used for sizing. In a non-demo scenario, there would be a more useful view.
    let box: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yellow

        box.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(box)

        NSLayoutConstraint.activate([
            box.topAnchor.constraint(equalTo: view.topAnchor),
            box.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            box.widthAnchor.constraint(equalToConstant: 200),
            box.heightAnchor.constraint(equalToConstant: 200),
        ])

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
    }

    // MARK : - BottomDrawer

    var heightForDefaultVisibility: CGFloat {
        view.layoutIfNeeded()
        return box.frame.height
    }

    var bottomLayoutAnchorForDefaultVisibility: NSLayoutAnchor<NSLayoutYAxisAnchor> {
        return box.bottomAnchor
    }

}
