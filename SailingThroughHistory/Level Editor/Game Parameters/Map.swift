//
//  Map.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Map: Codable {
    var map = "worldmap1815"
    var nodes = [Node]()
    var paths = [GameObject: [Path]]()

    func addMap(_ map: String) {
        self.map = map
    }

    func addNode(_ node: Node) {
        nodes.append(node)
    }

    func add(path: Path) {
        if paths[path.fromObject] == nil {
            paths[path.fromObject] = []
        }

        if paths[path.toObject] == nil {
            paths[path.toObject] = []
        }

        paths[path.fromObject]?.append(path)
        paths[path.toObject]?.append(path)
    }

    func findNode(at point: CGPoint) -> Node? {
        for node in nodes where node.frame.origin == point {
            return node
        }
        return nil
    }
}
