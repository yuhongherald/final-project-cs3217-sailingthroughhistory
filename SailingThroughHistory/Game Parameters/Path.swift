//
//  Path.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

/**
 * Model for path to store two ends of the path as well as volatiles in the path.
 */
class Path: Hashable, Codable {
    let fromNode: Node
    let toNode: Node
    var modifiers = [Volatile]()

    init(from fromObject: Node, to toObject: Node) {
        self.fromNode = fromObject
        self.toNode = toObject
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fromNode = try values.decode(Node.self, forKey: .fromNode)
        toNode = try values.decode(Node.self, forKey: .toNode)

        var volatilesArrayForType = try values.nestedUnkeyedContainer(forKey: CodingKeys.modifiers)
        while !volatilesArrayForType.isAtEnd {
            let volatile = try volatilesArrayForType.nestedContainer(keyedBy: VolatileTypeKey.self)
            let type = try volatile.decode(VolatileTypes.self, forKey: VolatileTypeKey.type)

            switch type {
            case .volatileMonsoom:
                let volatile = try volatile.decode(VolatileMonsoon.self, forKey: VolatileTypeKey.volatile)
                modifiers.append(volatile)
            case .weather:
                let volatile = try volatile.decode(Weather.self, forKey: VolatileTypeKey.volatile)
                modifiers.append(volatile)
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fromNode, forKey: .fromNode)
        try container.encode(toNode, forKey: .toNode)

        var volatileWithType = [VolatileWithType]()
        for volatile in modifiers {
            if volatile is VolatileMonsoon {
                volatileWithType.append(VolatileWithType(volatile: volatile, type: VolatileTypes.volatileMonsoom))
            }
            if volatile is Weather {
                volatileWithType.append(VolatileWithType(volatile: volatile, type: VolatileTypes.weather))
            }
        }
        try container.encode(volatileWithType, forKey: .modifiers)
    }

    static func == (lhs: Path, rhs: Path) -> Bool {
        return (lhs.fromNode, lhs.toNode) == (rhs.fromNode, rhs.toNode)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fromNode)
        hasher.combine(toNode)
    }

    /// Compute the steps required for a player to go through the path. Influenced by volatile modifiers.
    func computeCostOfPath(baseCost: Double, with ship: Pirate_WeatherEntity) -> Double {
        var result = baseCost
        for modifier in modifiers {
            result = Double(modifier.applyVelocityModifier(to: Float(result), with: Float(ship.getWeatherModifier())))
        }
        return result
    }

    enum CodingKeys: String, CodingKey {
        case fromNode
        case toNode
        case modifiers
    }

    enum VolatileTypeKey: String, CodingKey {
        case type
        case volatile
    }

    enum VolatileTypes: String, Codable {
        case volatileMonsoom
        case weather
    }

    struct VolatileWithType: Codable {
        var volatile: Volatile
        var type: VolatileTypes

        init(volatile: Volatile, type: VolatileTypes) {
            self.volatile = volatile
            self.type = type
        }
    }
}
