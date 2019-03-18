//
//  Player.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Player: GenericPlayer {
    public let money = GameVariable(value: 0)
    public let state = GameVariable(value: PlayerState.endTurn)

    private let ship: Ship
    
    required public init(node: Node) {
        ship = Ship(node: node)
    }

    func buyUpgrade(upgrade: Upgrade) {
    }
    
    func getOwnedPorts() -> [Port] {
        return []
    }
    
    func setTax(port: Port) {
    }
    
    func move(node: Node) {
        ship.move(node: node)
    }
    
    func getNodesInRange(roll: Int) -> [Node] {
        return ship.getNodesInRange(roll: roll)
    }
    
    func canDock() -> Bool {
        return false
    }
    
    func dock() {
    }
    
    func getMaxPurchaseAmount(itemType: ItemType) -> Int {
        return 0
    }
    
    func getMaxSellAmount(itemType: ItemType) -> Int {
        return 0
    }
    
    func buy(itemType: ItemType, quantity: Int) {
    }
    
    func sell(itemType: ItemType, quantity: Int) {
    }
    
    func endTurn() {
    }
}
