//
//  PirateUI.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class PirateIsland: GameObject {
    private static let pirateNodeHeight: Double = 50
    private static let pirateNodeWidth: Double = 50
    let influence = 3
    let chance = 0.2

    init(in node: Node) {
        super.init(frame: node.frame)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
