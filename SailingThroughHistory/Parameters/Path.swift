//
//  Path.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

struct Path: Hashable, Codable {
    let fromObject: GameObject
    let toObject: GameObject
    var modifiers = [VolatileModifier]()

    init(from fromObject: GameObject, to toObject: GameObject) {
        self.fromObject = fromObject
        self.toObject = toObject
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fromObject = try values.decode(GameObject.self, forKey: .fromObject)
        toObject = try values.decode(GameObject.self, forKey: .toObject)
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(GameObject(images: fromObject.images,
                                        frame: fromObject.frame,
                                        loopDuration: fromObject.loopDuration,
                                        startingFrame: fromObject.startingFrame), forKey: .fromObject)
        try container.encode(GameObject(images: toObject.images,
                                        frame: toObject.frame,
                                        loopDuration: toObject.loopDuration,
                                        startingFrame: toObject.startingFrame), forKey: .toObject)
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
