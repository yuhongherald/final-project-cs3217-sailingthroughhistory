//
//  UniformRandom.swift
//  SailingThroughHistory
//
//  Created by Herald on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class UniformRandom: Randomable {
    func random() -> Double {
        return Double(Float.random())
    }
}
