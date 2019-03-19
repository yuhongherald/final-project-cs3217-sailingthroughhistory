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
    func getMaxPurchaseAmount(itemType: ItemType) -> Int
    func getMaxSellAmount(itemType: ItemType) -> Int
    func buy(itemType: ItemType, quantity: Int)
    func sell(itemType: ItemType, quantity: Int)

    // End turn - supplies are removed here
    func endTurn()
}
