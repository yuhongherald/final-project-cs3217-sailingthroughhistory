//
//  Pirate.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//
import UIKit

class Pirate: Node, VolatileModifier {
    var isActive = false
    private static let pirateNodeSize = CGSize(width: 50, height: 50)
    private static let pirateNodeImage = "pirate-node.png"

    init(name: String, pos: CGPoint) {
        super.init(name: name, image: Pirate.pirateNodeImage, frame: CGRect(origin: pos, size: Pirate.pirateNodeSize))
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
