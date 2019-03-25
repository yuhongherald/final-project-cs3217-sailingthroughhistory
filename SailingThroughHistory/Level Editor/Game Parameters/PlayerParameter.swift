//
//  PlayerParameter.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class PlayerParameter: Codable {
    private var name: String
    private var money = GameVariable(value: 0)
    private var port: Port?

    init(name: String) {
        self.name = name
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        let moneyValue = try values.decode(Int.self, forKey: .money)
        port = try values.decode(Port?.self, forKey: .node)
        money = GameVariable(value: moneyValue)
    }

    func getPlayer() -> Player? {
        guard let unwrappedPort = port else {
            return nil
        }
        return Player(name: name, node: unwrappedPort)
    }

    func getName() -> String {
        return name
    }

    func getMoney() -> Int {
        return money.value
    }

    func getPort() -> Port? {
        return port
    }

    func set(name: String, money: Int?) {
        if name != "" {
            self.name = name
        }

        if let unwrappedMoney = money {
            self.money = GameVariable(value: unwrappedMoney)
        }
    }

    func assign(port: Port) {
        self.port = port
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(money.value, forKey: .money)
        try container.encode(port, forKey: .node)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case money
        case node
    }
}
