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

    public func buyUpgrade(upgrade: Upgrade) {
    }
    
    public func getOwnedPorts() -> [Port] {
        return []
    }
    
    public func setTax(port: Port, amount: Int) {
        port.taxAmount = amount
    }
    
    public func move(node: Node) {
        ship.move(node: node)
    }
    
    public func getNodesInRange(roll: Int) -> [Node] {
        return ship.getNodesInRange(roll: roll)
    }
    
    public func canDock() -> Bool {
        return ship.canDock()
    }
    
    public func dock() {
        let port = ship.dock()
        port?.collectTax(from: self)
    }
    
    public func getMaxPurchaseAmount(itemType: ItemType) -> Int {
        return 0
    }
    
    public func getMaxSellAmount(itemType: ItemType) -> Int {
        return 0
    }
    
    public func buy(itemType: ItemType, quantity: Int) {
    }
    
    public func sell(itemType: ItemType, quantity: Int) {
    }
    
    public func endTurn() {
    }
}

// MARK - Equatable
extension Player: Equatable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs === rhs
    }
}
