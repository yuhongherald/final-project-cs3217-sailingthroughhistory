//
//  Team.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/28/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Represents a team in the game.
import Foundation

class Team: GenericTeam {
    var name: String
    var money: GameVariable<Int> = GameVariable(value: 0)
    var startingNode: Node? {
        didSet {
            self.startId = startingNode?.identifier
        }
    }
    private(set) var startId: Int?

    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.name == rhs.name
    }

    required init(name: String) {
        self.name = name
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        money.value = try values.decode(Int.self, forKey: .money)
        startId = try values.decode(Int?.self, forKey: .startId)
        assert(checkRep())
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(money.value, forKey: .money)
        try container.encode(startId, forKey: .startId)
    }

    func updateMoney(by amount: Int) {
        self.money.value += amount
    }

    func start(from node: Node) {
        assert(checkRep())
        self.startingNode = node
        assert(checkRep())
    }

    private func checkRep() -> Bool {
        if self.startingNode == nil {
            return true
        }
        return self.startingNode?.identifier == self.startId
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case money
        case startId
    }
}

extension Team: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
