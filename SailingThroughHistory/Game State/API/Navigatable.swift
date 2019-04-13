//
//  Navigatable.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol Navigatable {
    func getNodesInRange(roll: Int, speedMultiplier: Double, map: Map) -> [Node]
    func move(node: Node)
    func canDock() -> Bool
    func dock() throws -> Port
}
