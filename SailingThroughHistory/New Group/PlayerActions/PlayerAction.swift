//
//  PlayerAction.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

enum PlayerAction: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(Identifier.self, forKey: .type)
        switch type {
        case .changeInventory:
            let changeType = try container.decode(ChangeType.self, forKey: .changeType)
            let money = try container.decode(Int.self, forKey: .money)
            let items = try container.decode([Item].self, forKey: .items)
            self = .changeInventory(changeType: changeType, money: money, items: items)
        case .roll:
            self = .roll
        case .move:
            let node = try container.decode(Node.self, forKey: .node)
            self = .move(to: node)
        case .forceMove:
            let node = try container.decode(Node.self, forKey: .node)
            self = .forceMove(to: node)
        case .setTax:
            let port = try container.decode(Port.self, forKey: .node)
            let taxAmount = try container.decode(Int.self, forKey: .taxAmount)
            self = .setTax(for: port, taxAmount: taxAmount)
        case .setEvent:
            self = .roll
        default:
            self = .roll // TODO: Make items decodable
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .changeInventory(let changeType, let money, let items):
            try container.encode(Identifier.changeInventory, forKey: .type)
            try container.encode(changeType, forKey: .changeType)
            try container.encode(money, forKey: .money)
            try container.encode(items, forKey: CodingKeys.type)
        case .roll:
            try container.encode(Identifier.roll, forKey: .type)
        case .move(let node):
            try container.encode(Identifier.move, forKey: .type)
            try container.encode(node, forKey: .node)
        case .forceMove(let node):
            try container.encode(Identifier.forceMove, forKey: .type)
            try container.encode(node, forKey: .node)
        case .setTax(let port, let taxAmount):
            try container.encode(Identifier.setTax, forKey: .type)
            try container.encode(port, forKey: .node)
            try container.encode(taxAmount, forKey: .taxAmount)
        case .setEvent(let changeType, let events):
            break
        default:
            break // TODO: Make new events encodable
        }
    }

    case changeInventory(changeType: ChangeType, money: Int, items: [Item]) // deprecated
    case buyOrSell(player: GenericPlayer, itemParamter: ItemParameter, item: Int)
    case roll
    case move(to: Node)
    case forceMove(to: Node)
    //case moveSequence() // TODO
    case setTax(for: Port, taxAmount: Int)
    case setEvent(changeType: ChangeType, events: [TurnSystemEvent])

    private enum Identifier: String, Codable {
        case changeInventory
        case buyOrSell
        case roll
        case move
        case forceMove
        case setTax
        case setEvent
    }

    enum CodingKeys: String, CodingKey {
        case type
        case changeType
        case money
        case node
        case items
        case taxAmount
    }
}
