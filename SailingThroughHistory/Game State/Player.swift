//
//  Player.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Player: GenericPlayer {
    let money = GameVariable(value: 0)
    let state = GameVariable(value: PlayerState.endTurn)
    var name: String
    var interface: Interface?
    // TODO: should startingNode: Node without ?
    var startingNode: Node?

    private let ship: Ship
    private var shipChassis: ShipChassis?
    private var auxiliaryUpgrade: AuxiliaryUpgrade?

    required init(name: String, node: Node) {
        self.name = name
        self.startingNode = node
        ship = Ship(node: node, suppliesConsumed: [])
        ship.setOwner(owner: self)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        startingNode = try values.decode(Node.self, forKey: .startingNode)

        guard let node = startingNode else {
            fatalError("Node not initialized, cannot initialzed ship")
        }
        ship = Ship(node: node, suppliesConsumed: [])
        ship.setOwner(owner: self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(startingNode, forKey: .startingNode)
    }

    func startTurn() {
        ship.startTurn()
    }

    func buyUpgrade(upgrade: Upgrade) {
        ship.installUpgade(upgrade: upgrade)
    }

    func setTax(port: Port, amount: Int) {
        port.taxAmount = amount
    }

    func move(node: Node) {
        ship.move(node: node)
    }

    func getNodesInRange(roll: Int) -> [Node] {
        return ship.getNodesInRange(roll: roll)
    }

    func canDock() -> Bool {
        return ship.canDock()
    }

    func dock() {
        let port = ship.dock()
        port?.collectTax(from: self)
    }

    func getPurchasableItemParameters() -> [ItemParameter] {
        return ship.getPurchasableItemParameters()
    }

    func getMaxPurchaseAmount(itemParameter: ItemParameter) -> Int {
        return ship.getMaxPurchaseAmount(itemParameter: itemParameter)
    }

    func buy(itemParameter: ItemParameter, quantity: Int) {
        ship.buyItem(itemParameter: itemParameter, quantity: quantity)
    }

    func sell(item: GenericItem) {
        ship.sellItem(item: item)
    }

    func endTurn() {
        ship.endTurn()
    }

    private enum CodingKeys: String, CodingKey
    {
        case name
        case startingNode
    }
}
