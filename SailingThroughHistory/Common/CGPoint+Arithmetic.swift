//
//  CGPoint+Arithmetic.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

extension CGPoint {
    static func + (point1: CGPoint, point2: CGPoint) -> CGPoint {
        return CGPoint(x: point1.x + point2.x, y: point1.y + point2.y)
    }

    static func * (point: CGPoint, multiplier: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * multiplier, y: point.y * multiplier)
    }
}
