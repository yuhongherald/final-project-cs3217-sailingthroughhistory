//
//  Node.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Node: Codable {
    let name: String
    let image: String
    let frame: CGRect

    init(name: String, image: String, frame: Rect) {
        self.name = name
        self.image = image
        self.frame = CGRect()
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        image = try values.decode(String.self, forKey: .image)
        frame = try values.decode(CGRect.self, forKey: .frame)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encode(image, forKey: .image)
        try container.encode(frame, forKey: .frame)
    }

    func getNodesInRange(ship: Pirate_WeatherEntity, range: Double, map: Map) -> [Node] {
        var result = [Node]()
        guard range >= 0 else {
            return result
        }
        result.append(self)
        for path in map.getPaths(of: self) {
            let neighbour = path.toNode
            let remainingMovement = range - path.computeCostOfPath(baseCost: 1, with: ship)
            result += neighbour.getNodesInRange(ship: ship, range: remainingMovement, map: map)
        }
        return result
    }

    func moveIntoNode(ship: Pirate_WeatherEntity) {
    }

    private enum CodingKeys: String, CodingKey {
        case identifier
        case name
        case image
        case frame
    }
}

extension Node: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    static func == (lhs: Node, rhs: Node) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
