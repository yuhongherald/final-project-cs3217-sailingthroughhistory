//
//  CGRect+Rect.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 25/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

extension CGRect {
    init(fromRect rect: Rect) {
        self.init(x: rect.originX, y: rect.originY, width: rect.width, height: rect.height)
    }

    func toRect() -> Rect {
        guard let rect = Rect(originX: Double(origin.x), originY: Double(origin.y),
                              height: Double(height), width: Double(width)) else {
            fatalError("CGRect should never be an invalid Rect.")
        }

        return rect
    }
}
