//
//  View+SpecialEffects.swift
//  GameEngine
//
//  Created by Jason Chong on 17/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//
import UIKit

extension UIView {
    /// Adds a glow of the input color to the view.
    ///
    /// - Parameter color: `UIColor` of the glow.
    func addGlow(colored color: UIColor) {
        layer.shadowOffset = .zero
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 20
        layer.shadowOpacity = 1
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }

    /// Removes glow from the view.
    ///
    /// - Parameter color: `UIColor` of the glow.
    func removeGlow() {
        layer.shadowOpacity = 0
    }
}
