//
//  Pirate.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class Pirate: Node, VolatileModifier {
    var isActive = false
    private static let pirateNodeHeight: Double = 50
    private static let pirateNodeWidth: Double = 50
    private static let pirateNodeImage = "pirate-node.png"

    init(name: String, originX: Double, originY: Double) {
        guard let frame = Rect(originX: originX, originY: originY, height: Pirate.pirateNodeHeight,
                               width: Pirate.pirateNodeWidth) else {
            fatalError("Pirate node dimensions are invalid.")
        }
        super.init(name: name, image: Pirate.pirateNodeImage, frame: frame)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
