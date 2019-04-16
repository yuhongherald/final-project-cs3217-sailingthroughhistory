//
//  ComparablePair.swift
//  SailingThroughHistory
//
//  Created by henry on 11/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

/// Compare by weight
struct ComparablePair<T>: Comparable {
    public let object: T
    public let weight: Double

    init(object: T, weight: Double) {
        self.object = object
        self.weight = weight
    }

    static func < (lhs: ComparablePair, rhs: ComparablePair) -> Bool {
        return lhs.weight < rhs.weight
    }

    static func == (lhs: ComparablePair, rhs: ComparablePair) -> Bool {
        return lhs.weight == rhs.weight
    }
}
