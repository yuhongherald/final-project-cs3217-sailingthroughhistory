//
//  ShipNavigationManager.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Manages the movement behavior of a ship. Computes movement and handles docking.
import Foundation

class ShipNavigationManager: Navigatable {
    func getNodesInRange(ship: ShipAPI, roll: Int, speedMultiplier: Double) -> [Node] {
        guard let map = ship.map else {
            fatalError("Ship does not reside on map.")
        }
        let startNode = ship.node
        let movement = computeMovement(ship: ship, roll: roll, speedMultiplier: speedMultiplier)
        let nodesFromStart = startNode.getNodesInRange(ship: ship, range: movement, map: map)
        return nodesFromStart
    }

    func move(ship: inout ShipAPI, node: Node) {
        guard let currentFrame = ship.shipObject?.frame.value else {
            return
        }
        ship.nodeId = node.identifier
        let nodeFrame = node.frame
        if node is Sea {
            ship.isDocked = false
        }
        ship.shipObject?.frame.value = currentFrame.movedTo(
            originX: nodeFrame.originX, originY: nodeFrame.originY)
    }

    func canDock(ship: ShipAPI) -> Bool {
        guard let map = ship.map else {
            return false
        }
        return map.nodeIDPair[ship.nodeId] as? Port != nil
    }

    func dock(ship: inout ShipAPI) throws -> Port {
        guard canDock(ship: ship) else {
            throw MovementError.unableToDock
        }
        guard let port = ship.map?.nodeIDPair[ship.nodeId] as? Port else {
            throw MovementError.invalidPort
        }

        ship.isDocked = true
        ship.isChasedByPirates = false
        ship.turnsToBeingCaught = 0
        return port
    }

    private func computeMovement(ship: ShipAPI, roll: Int, speedMultiplier: Double) -> Double {
        var multiplier = 1.0
        multiplier = applyMovementModifiers(ship: ship, to: multiplier)
        return Double(roll) * speedMultiplier * multiplier
    }

    private func applyMovementModifiers(ship: ShipAPI, to multiplier: Double) -> Double {
        var result = multiplier
        result *= ship.shipChassis?.getMovementModifier() ?? 1
        result *= ship.auxiliaryUpgrade?.getMovementModifier() ?? 1
        return result
    }
}
