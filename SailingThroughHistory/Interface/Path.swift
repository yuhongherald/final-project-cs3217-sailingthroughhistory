//
//  Path.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

struct Path: Hashable, Codable {
    let fromObject: GameObject
    let toObject: GameObject

    init(from fromNode: GameObject, to toNode: GameObject) {
        fromObject = fromNode
        toObject = toNode
    }
}
