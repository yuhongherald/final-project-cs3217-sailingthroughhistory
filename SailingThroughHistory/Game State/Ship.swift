//
//  Ship.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Ship {
    private var location: Node?
    private var items = [Item]()
    private var capacity = 0
    private var chassis: Upgrade?
    private var axuxiliaryUpgrade: Upgrade?
    
    public func getNodesInRange() -> [Node] {
        return []
    }
    
    public func move() {
        
    }
    
    private func computeMovement(roll: Int) -> Double {
        var multiplier = 1.0
        return Double(roll)
    }
    
    private func applyUpgradesModifiers(to multiplier: Double) -> Double {
        return multiplier
    }
    
    private func applyEnvironmentModifiers(to multiplier: Double) -> Double {
        return multiplier
    }
}
