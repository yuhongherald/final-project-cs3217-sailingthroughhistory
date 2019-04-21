//
//  Navigatable.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Defines operations for moving a ship around. Stateless.
import Foundation

protocol Navigatable {
    func getNodesInRange(ship: ShipAPI, roll: Int, speedMultiplier: Double) -> [Node]
    func move(ship: inout ShipAPI, node: Node)
    func canDock(ship: ShipAPI) -> Bool
    func dock(ship: inout ShipAPI) throws -> Port
}
