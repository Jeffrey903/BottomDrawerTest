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

    let minimizeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleMinimize(_:)), for: .touchUpInside)
        button.setTitle("Minimize", for: .normal)
        return button
    }()

    let defaultButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleDefault(_:)), for: .touchUpInside)
        button.setTitle("Default", for: .normal)
        return button
    }()

    let expandedButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleExpanded(_:)), for: .touchUpInside)
        button.setTitle("Expanded", for: .normal)
        return button
    }()

    lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [minimizeButton, defaultButton, expandedButton])
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let contentsViewController = ContentsViewController()
        bottomDrawer = BottomDrawerViewController(withPresenting: self, child: contentsViewController)

        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsStackView)

        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.text = "Tap or swipe up on bottom drawer to open"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: buttonsStackView.trailingAnchor, multiplier: 2),
            buttonsStackView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2),

            label.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: label.trailingAnchor, multiplier: 2),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(contentsViewController.heightForDefaultVisibility + 20)),
        ])
    }

    @objc func handleMinimize(_ sender: UIButton) {
        bottomDrawer?.setVisibility(.minimized, animated: true)
    }

    @objc func handleDefault(_ sender: UIButton) {
        bottomDrawer?.setVisibility(.default, animated: true)
    }

    @objc func handleExpanded(_ sender: UIButton) {
        bottomDrawer?.setVisibility(.expanded, animated: true)
    }

}
