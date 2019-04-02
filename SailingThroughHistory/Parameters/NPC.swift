//
//  NPC.swift
//  SailingThroughHistory
//
//  Created by Herald on 21/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class NPC: GameObject {
    private static let NPCNodeHeight: Double = 50
    private static let NPCNodeWidth: Double = 50
    private static let NPCNodeImage = "pirate-node.png"

    init(name: String, originX: Double, originY: Double) {
        guard let frame = Rect(originX: originX, originY: originY, height: NPC.NPCNodeHeight, width: NPC.NPCNodeWidth) else {
                                fatalError("Pirate node dimensions are invalid.")
        }
        super.init(image: NPC.NPCNodeImage, frame: frame)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
