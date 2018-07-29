//
//  ViewController.swift
//  BottomDrawerTest
//
//  Created by Jeff Grossman on 7/28/18.
//  Copyright © 2018 Jeff Grossman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var bottomDrawer: BottomDrawerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let contentsViewController = ContentsViewController()
        bottomDrawer = BottomDrawerViewController(withPresenting: self, child: contentsViewController)

        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.text = "Tap or swipe up on bottom drawer to open"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: label.trailingAnchor, multiplier: 2),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(contentsViewController.heightForDefaultVisibility + 20)),
        ])
    }

}
