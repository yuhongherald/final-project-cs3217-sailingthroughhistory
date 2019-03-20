//
//  GenericPlayer.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol GenericPlayer {
    var money: GameVariable<Int> { get }
    var state: GameVariable<PlayerState> { get }
    
    init(node: Node)
    
    // Before moving
    func buyUpgrade(upgrade: Upgrade)
    func getOwnedPorts() -> [Port]
    func setTax(port: Port)
    
    // Moving - Auto progress to End turn if cannot dock
    func move(node: Node)
    func getNodesInRange(roll: Int) -> [Node]

    // After moving can choose to dock
    func canDock() -> Bool
    func dock()
    
    // Docked - End turn is manual here
    func getMaxPurchaseAmount(itemType: ItemParameter) -> Int
    func getMaxSellAmount(itemType: ItemParameter) -> Int
    func buy(itemType: ItemParameter, quantity: Int)
    func sell(itemType: ItemParameter, quantity: Int)
    
    // End turn - supplies are removed here
    func endTurn()
}
