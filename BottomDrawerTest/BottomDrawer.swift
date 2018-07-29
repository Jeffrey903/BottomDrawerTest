//
//  BottomDrawer.swift
//  BottomDrawerTest
//
//  Created by Jeff Grossman on 7/29/18.
//  Copyright © 2018 Jeff Grossman. All rights reserved.
//

import UIKit

protocol BottomDrawer {

    var heightForDefaultVisibility: CGFloat { get }

    var bottomLayoutAnchorForDefaultVisibility: NSLayoutAnchor<NSLayoutYAxisAnchor> { get }

}
