//
//  Node.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Node: Codable {
    static var nextID: Int = 0
    let identifier: Int
    let name: String
    let frame: Rect
    var objects: [GameObject] = []

    init(name: String, frame: Rect) {
        self.name = name
        self.frame = frame
        self.identifier = Node.nextID
        Node.nextID += 1
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(Int.self, forKey: .identifier)
        name = try values.decode(String.self, forKey: .name)
        frame = try values.decode(Rect.self, forKey: .frame)
        objects = try values.decode([GameObject].self, forKey: .objects)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(name, forKey: .name)
        try container.encode(frame, forKey: .frame)
        try container.encode(objects, forKey: .objects)
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

    func add(object: GameObject) {
        self.objects.append(object)
    }

    private enum CodingKeys: String, CodingKey {
        case identifier
        case name
        case image
        case frame
        case objects
    }
}

extension Node: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
