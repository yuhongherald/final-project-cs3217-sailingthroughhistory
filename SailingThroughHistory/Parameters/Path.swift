//
//  Path.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

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
        modifiers = try values.decode([Volatile].self, forKey: .modifiers)
    }

    static func == (lhs: Path, rhs: Path) -> Bool {
        return (lhs.fromNode, lhs.toNode) == (rhs.fromNode, rhs.toNode)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fromNode)
        hasher.combine(toNode)
    }

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
}
