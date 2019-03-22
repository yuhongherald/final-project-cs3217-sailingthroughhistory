//
//  PlayerParameter.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class PlayerParameter: Codable {
    private var name: String!
    private var money: GameVariable<Int>!
    private var node: Node!

    init(name: String, money: Int, node: Node) {
        self.name = name
        self.money = GameVariable(value: money)
        self.node = node
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        let moneyValue = try values.decode(Int.self, forKey: .money)
        let node = try values.decode(Node.self, forKey: .node)
        money = GameVariable(value: moneyValue)
    }

    func getPlayer() -> Player {
        return Player(name: name, node: node)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(money.value, forKey: .money)
        try container.encode(node, forKey: .node)
    }

    enum CodingKeys: String, CodingKey
    {
        case name
        case money
        case node
    }
}
