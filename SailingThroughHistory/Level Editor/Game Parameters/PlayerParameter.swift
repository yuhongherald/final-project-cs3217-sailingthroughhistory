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
    private var teamName: String
    private var money = GameVariable(value: 0)
    private var startingNode: Node?

    init(name: String, teamName: String, node: Node?) {
        self.name = name
        self.teamName = teamName
        self.startingNode = node
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        teamName = try values.decode(String.self, forKey: .teamName)
        let moneyValue = try values.decode(Int.self, forKey: .money)
        startingNode = try values.decode(Node?.self, forKey: .node)
        money = GameVariable(value: moneyValue)
    }

    func getName() -> String {
        return name
    }

    func getTeam() -> Team {
        return Team(name: teamName)
    }

    func getMoney() -> Int {
        return money.value
    }

    func set(name: String, money: Int?) {
        if name != "" {
            self.name = name
        }

        if let unwrappedMoney = money {
            self.money = GameVariable(value: unwrappedMoney)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(teamName, forKey: .teamName)
        try container.encode(money.value, forKey: .money)
        try container.encode(startingNode, forKey: .node)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case teamName
        case money
        case node
    }
}
