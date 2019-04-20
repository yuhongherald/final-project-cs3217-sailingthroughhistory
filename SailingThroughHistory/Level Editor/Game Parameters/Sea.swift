//
//  Sea.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class Sea: Node {
    private static let seaNodeWidth: Double = 50
    private static let seaNodeHeight: Double = 50

    init(name: String, originX: Double, originY: Double) {
        let frame = Rect(originX: originX, originY: originY, height: Sea.seaNodeHeight,
                               width: Sea.seaNodeWidth)
        super.init(name: name, frame: frame)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
