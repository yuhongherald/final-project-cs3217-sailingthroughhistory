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
    private var items = [GenericItem]()
    private var weightCapacity = 0
    private var chassis: Upgrade?
    private var axuxiliaryUpgrade: Upgrade?
    
    public init(node: Node)
    {
        let location = Location(start: node, end: node, fractionToEnd: 0, isDocked: node is Port)
        self.location = GameVariable(value: location)
    }
    
    // Movement
    
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
    
    public func canDock() -> Bool {
        return location.value.fractionToEnd == 0 && location.value.start is Port
    }
    
    public func dock() -> Port? {
        guard canDock() else {
            // TODO: Show some error
            return nil
        }
        guard let port = location.value.start as? Port else {
            return nil
        }
        location.value = Location(from: location.value, isDocked: true)
        return port
    }
    
    // Items
    
    public func getRemainingCapacity() -> Int {
        var remainingCapacity = weightCapacity
        for item in items {
            remainingCapacity -= item.weight
        }
        return remainingCapacity
    }
    
    public func addItem(item: GenericItem) {
        if getRemainingCapacity() < item.weight {
            
        }
    }
    
    public func removeItem(item: GenericItem) {
        
    }
    
    // Helper functions
    
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
