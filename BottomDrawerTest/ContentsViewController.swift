//
//  ContentsViewController.swift
//  BottomDrawerTest
//
//  Created by Jeff Grossman on 7/29/18.
//  Copyright © 2018 Jeff Grossman. All rights reserved.
//

import UIKit

class ContentsViewController: UIViewController, BottomDrawer {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yellow

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
        ])
    }
    
    func expandedHeight() -> CGFloat {
        return 600
    }
    
    func collapsedHeight() -> CGFloat {
        return 200
    }

}
