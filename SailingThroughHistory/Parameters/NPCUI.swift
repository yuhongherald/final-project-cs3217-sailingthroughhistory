//
//  NPCUI.swift
//  SailingThroughHistory
//
//  Created by Herald on 21/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class NPCUI: GameObject {
    private static let NPCNodeHeight: Double = 50
    private static let NPCNodeWidth: Double = 50

    init(in node: Node) {
        super.init(frame: node.frame)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
