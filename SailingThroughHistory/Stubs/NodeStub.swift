//
//  NodeStub.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class NodeStub: Node {
    required init(name: String, identifier: Int) {
        Node.nextID = identifier
        Node.reuseID.removeAll()
        let frame = Rect(originX: 0, originY: 0, height: 0, width: 0)
        super.init(name: name, frame: frame)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
