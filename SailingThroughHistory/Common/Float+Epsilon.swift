//
//  Float+Epsilon.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

extension Float {
    // largest value engine is designed to handle
    static let infinity: Float = 1e9
    static let epsilon: Float = 1e-6
    static let sqrt3: Float = sqrt(3)

    // randoms between 0 and 1
    static func random() -> Float {
        return Float(arc4random()) / Float(UINT32_MAX)
    }
}
