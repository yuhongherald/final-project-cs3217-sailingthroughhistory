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
        case .move:
            let node = try container.decode(Int.self, forKey: .nodeId)
            self = .move(toNodeId: node)
        case .forceMove:
            let node = try container.decode(Int.self, forKey: .nodeId)
            self = .forceMove(toNodeId: node)
        case .setTax:
            let port = try container.decode(Int.self, forKey: .nodeId)
            let taxAmount = try container.decode(Int.self, forKey: .taxAmount)
            self = .setTax(forPortId: port, taxAmount: taxAmount)
        case .buyOrSell:
            let itemType = try container.decode(ItemType.self, forKey: .itemType)
            let quantity = try container.decode(Int.self, forKey: .quantity)
            self = .buyOrSell(itemType: itemType, quantity: quantity)
        case .purchaseUpgrade:
            let type = try container.decode(UpgradeType.self, forKey: .itemType)
            self = .purchaseUpgrade(type: type)
        case .pirate:
            self = .pirate
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .move(let node):
            try container.encode(Identifier.move, forKey: .type)
            try container.encode(node, forKey: .nodeId)
        case .forceMove(let node):
            try container.encode(Identifier.forceMove, forKey: .type)
            try container.encode(node, forKey: .nodeId)
        case .setTax(let port, let taxAmount):
            try container.encode(Identifier.setTax, forKey: .type)
            try container.encode(port, forKey: .nodeId)
            try container.encode(taxAmount, forKey: .taxAmount)
        case .buyOrSell(let itemType, let quantity):
            try container.encode(Identifier.buyOrSell, forKey: .type)
            try container.encode(itemType, forKey: .itemType)
            try container.encode(quantity, forKey: .quantity)
        case .purchaseUpgrade(let upgradeType):
            try container.encode(Identifier.purchaseUpgrade, forKey: .type)
            try container.encode(upgradeType, forKey: .upgrade)
        case .pirate:
            try container.encode(Identifier.pirate, forKey: .type)
            break
        }
    }

    case buyOrSell(itemType: ItemType, quantity: Int)
    case move(toNodeId: Int)
    case forceMove(toNodeId: Int)
    case purchaseUpgrade(type: UpgradeType)
    case setTax(forPortId: Int, taxAmount: Int)
    case pirate
    //case setEvent(changeType: ChangeType, events: [TurnSystemEvent])

    private enum Identifier: String, Codable {
        case buyOrSell
        case move
        case forceMove
        case setTax
        case purchaseUpgrade
        case pirate
        //case setEvent
    }

    enum CodingKeys: String, CodingKey {
        case type
        case nodeId
        case itemType
        case taxAmount
        case quantity
        case upgrade
    }
}
