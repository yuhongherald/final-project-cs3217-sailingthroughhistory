//
//  InterfacePath.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 24/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct InterfacePath: Hashable {
    let fromId: Int
    let toId: Int

    init(from fromId: Int, to toId: Int) {
        self.fromId = fromId
        self.toId = toId
    }
}
