//
//  GenericPlayer.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation
import RxSwift

protocol GenericPlayer: Codable {
    var name: String { get }
    var money: GameVariable<Int> { get }
    var state: GameVariable<PlayerState> { get }
    var interface: Interface? { get set }

    init(name: String, node: Node)
    
    // subscribes
    func subscribeToItems(with observer: @escaping (Event<[GenericItem]>) -> Void)
    func subscribeToCargoWeight(with observer: @escaping (Event<Int>) -> Void)
    func subscribeToWeightCapcity(with observer: @escaping (Event<Int>) -> Void)

    // Before moving
    func startTurn()
    func buyUpgrade(upgrade: Upgrade)
    func setTax(port: Port, amount: Int)

    // Moving - Auto progress to End turn if cannot dock
    func move(node: Node)
    func getNodesInRange(roll: Int) -> [Node]

    // After moving can choose to dock
    func canDock() -> Bool
    func dock()

    // Docked - End turn is manual here
    func getPurchasableItemParameters() -> [ItemParameter]
    func getMaxPurchaseAmount(itemParameter: ItemParameter) -> Int
    func buy(itemParameter: ItemParameter, quantity: Int)
    func sell(item: GenericItem)

    // End turn - supplies are removed here
    func endTurn()
}

func == (lhs: GenericPlayer, rhs: GenericPlayer?) -> Bool {
    return lhs.name == rhs?.name
}

func != (lhs: GenericPlayer, rhs: GenericPlayer?) -> Bool {
    return !(lhs == rhs)
}
