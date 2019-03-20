//
//  Location.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Location {
    public let start: Node
    public let end: Node
    public let fractionToEnd: Double
    public let isDocked: Bool

    public init(start: Node, end: Node, fractionToEnd: Double, isDocked: Bool) {
        self.start = start
        self.end = end
        // Clamp to 0 and 1
        self.fractionToEnd = isDocked ? 0 : min(1, max(0, fractionToEnd))
        self.isDocked = isDocked
    }

    public init(from location: Location, isDocked: Bool) {
        start = location.start
        end = location.end
        fractionToEnd = location.fractionToEnd
        self.isDocked = isDocked
    }
}
