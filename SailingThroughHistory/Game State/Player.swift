//
//  Player.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Player: GenericPlayer {
    public let name: String
    public let money = GameVariable(value: 0)
    public let state = GameVariable(value: PlayerState.endTurn)
    public var interface: Interface?

    private let ship: Ship
    
    required public init(name: String, node: Node) {
        self.name = name
        ship = Ship(node: node)
        ship.setOwner(owner: self)
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
    
    func getPurchasableItemTypes() -> [GenericItemType] {
        return ship.getPurchasableItemTypes()
    }
    
    public func getMaxPurchaseAmount(itemType: GenericItemType) -> Int {
        return ship.getMaxPurchaseAmount(itemType: itemType)
    }
    
    public func buy(itemType: GenericItemType, quantity: Int) {
        ship.buyItem(itemType: itemType, quantity: quantity)
    }
    
    public func sell(item: GenericItem) {
        ship.sellItem(item: item)
    }
    
    public func endTurn() {
    }
    
}
