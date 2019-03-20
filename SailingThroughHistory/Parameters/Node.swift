//
//  Node.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Node: GameObject {
    let name: String
    var neighbours = [Node]()

    init(name: String, image: String, frame: CGRect) {
        self.name = name
        super.init(image: image, frame: frame)
    }

    public func getNodesInRange(range: Double) -> [Node] {
        return []
    }
}
