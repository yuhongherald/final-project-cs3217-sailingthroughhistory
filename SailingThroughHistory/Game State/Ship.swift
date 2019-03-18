//
//  Ship.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Ship {
    private var location: GameVariable<Location>
    private var items = [ItemType]()
    private var capacity = 0
    private var chassis: Upgrade?
    private var axuxiliaryUpgrade: Upgrade?
    
    public init(node: Node)
    {
        let location = Location(start: node, end: node, fractionToEnd: 0, isDocked: node is Port)
        self.location = Variable(location)
    }
    
    public func getNodesInRange(roll: Int) -> [Node] {
        let movement = computeMovement(roll: roll)
        let nodesFromStart = location.value.start.getNodesInRange(range: movement - location.value.fractionToEnd)
        if location.value.fractionToEnd == 0 {
            return nodesFromStart
        }
        let nodesFromEnd = location.value.end.getNodesInRange(range: movement + 1 - location.value.fractionToEnd)
        return Array(Set(nodesFromStart + nodesFromEnd))
    }
    
    public func move(node: Node) {
        location.value = Location(start: node, end: node, fractionToEnd: 0, isDocked: false)
    }
    
    public func dock() -> Bool {
        if location.value.fractionToEnd > 0 {
            return false
        }
        location.value = Location(from: location.value, isDocked: true)
        return true
    }
    
    private func computeMovement(roll: Int) -> Double {
        var multiplier = 1.0
        multiplier = applyUpgradesModifiers(to: multiplier)
        return Double(roll) * multiplier
    }
    
    private func applyUpgradesModifiers(to multiplier: Double) -> Double {
        return multiplier
    }
    
    private func getWeatherModifier() -> Double {
        var multiplier = 1.0
        return multiplier
    }
}
