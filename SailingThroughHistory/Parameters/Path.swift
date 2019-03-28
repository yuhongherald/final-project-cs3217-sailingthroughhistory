//
//  Path.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

struct Path: Hashable, Codable {
    let fromObject: Node
    let toObject: Node
    var modifiers = [VolatileModifier]()

    init(from fromObject: Node, to toObject: Node) {
        self.fromObject = fromObject
        self.toObject = toObject
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fromObject = try values.decode(Node.self, forKey: .fromObject)
        toObject = try values.decode(Node.self, forKey: .toObject)
        // TODO: decode modifiers if needed
        modifiers = [VolatileModifier]()
    }

    static func == (lhs: Path, rhs: Path) -> Bool {
        return (lhs.fromObject, lhs.toObject) == (rhs.fromObject, rhs.toObject)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fromObject)
        hasher.combine(toObject)
    }

    func computeCostOfPath(baseCost: Double, with ship: Pirate_WeatherEntity) -> Double {
        var result = baseCost
        for modifier in modifiers {
            guard let weather = modifier as? Weather else {
                continue
            }
            result = Double(weather.applyVelocityModifier(to: Float(result)))
        }
        return result
    }

    enum CodingKeys: String, CodingKey {
        case fromObject
        case toObject
    }
}
