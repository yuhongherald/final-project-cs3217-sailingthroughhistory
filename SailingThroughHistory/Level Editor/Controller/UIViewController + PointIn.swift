//
//  UIViewController + PointIn.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/18/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.

//

import UIKit

extension UIViewController {
    /// Extension for detecting hit on path in level editor.
    /// Used for convenience to allow minor deviation of user tapping gesture.
    /// @IBInspectable Code from : https://stackoverflow.com/a/42511203
    final func isPoint(point: CGPoint, withinDistance distance: CGFloat, ofPath path: CGPath?) -> Bool {
        guard let castedPath = path else {
            return false
        }

        if let hitPath = CGPath( __byStroking: castedPath,
                                 transform: nil,
                                 lineWidth: distance,
                                 lineCap: CGLineCap.round,
                                 lineJoin: CGLineJoin.miter,
                                 miterLimit: 0) {

            let isWithinDistance = hitPath.contains(point)
            return isWithinDistance
        }
        return false
    }
}
