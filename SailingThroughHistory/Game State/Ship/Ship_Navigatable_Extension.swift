//
//  Ship_Navigatable_Extension.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

extension Ship: Navigatable {
    func getNodesInRange(roll: Int, speedMultiplier: Double, map: Map) -> [Node] {
        guard let startNode = map.nodeIDPair[nodeId] else {
            fatalError("Ship has invalid node id.")
        }

        let movement = computeMovement(roll: roll, speedMultiplier: speedMultiplier)
        let nodesFromStart = startNode.getNodesInRange(ship: self, range: movement, map: map)
        return nodesFromStart
    }

    func move(node: Node) {
        guard let currentFrame = shipObject?.frame.value else {
            return
        }
        self.nodeId = node.identifier
        let nodeFrame = node.frame
        isDocked = false
        shipObject?.frame.value = currentFrame.movedTo(originX: nodeFrame.originX,
                                                       originY: nodeFrame.originY)
    }

    func canDock() -> Bool {
        guard let map = map else {
            fatalError("Ship does not reside on any map.")
        }
        return map.nodeIDPair[nodeId] as? Port != nil
    }

    func dock() throws -> Port {
        guard let map = map else {
            fatalError("Ship does not reside on any map.")
        }
        guard canDock() else {
            throw MovementError.unableToDock
        }
        guard let port = map.nodeIDPair[nodeId] as? Port else {
            throw MovementError.invalidPort
        }

        isDocked = true
        isChasedByPirates = false
        turnsToBeingCaught = 0
        return port
    }

    private func computeMovement(roll: Int, speedMultiplier: Double) -> Double {
        var multiplier = 1.0
        multiplier = applyMovementModifiers(to: multiplier)
        return Double(roll) * speedMultiplier * multiplier
    }

    private func applyMovementModifiers(to multiplier: Double) -> Double {
        var result = multiplier
        result *= shipChassis?.getMovementModifier() ?? 1
        result *= auxiliaryUpgrade?.getMovementModifier() ?? 1
        return result
    }
}
