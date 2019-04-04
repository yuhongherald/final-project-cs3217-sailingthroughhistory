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
        var objectsArrayForType = try values.nestedUnkeyedContainer(forKey: CodingKeys.objects)
        while !objectsArrayForType.isAtEnd {
            let object = try objectsArrayForType.nestedContainer(keyedBy: ObjectTypeKey.self)
            let type = try object.decode(ObjectTypes.self, forKey: ObjectTypeKey.type)

            switch type {
            case .pirate:
                let object = try object.decode(Pirate.self, forKey: ObjectTypeKey.object)
                objects.append(object)
            case .shipUI:
                let object = try object.decode(ShipUI.self, forKey: ObjectTypeKey.object)
                objects.append(object)
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(name, forKey: .name)
        try container.encode(frame, forKey: .frame)

        var objectsWithType = [ObjectWithType]()
        for object in objects {
            if object is Pirate {
                objectsWithType.append(ObjectWithType(object: object, type: ObjectTypes.pirate))
            }
            if object is ShipUI {
                objectsWithType.append(ObjectWithType(object: object, type: ObjectTypes.shipUI))
            }
        }
        try container.encode(objectsWithType, forKey: .objects)
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

    enum ObjectTypeKey: String, CodingKey {
        case type
        case object
    }

    enum ObjectTypes: String, Codable {
        case pirate
        case shipUI
    }

    struct ObjectWithType: Codable, Hashable {
        var object: GameObject
        var type: ObjectTypes

        init(object: GameObject, type: ObjectTypes) {
            self.object = object
            self.type = type
        }
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

// Mark : - Information
extension Node {

    func getNodesInRange(ship: Pirate_WeatherEntity, range: Double, map: Map) -> [Node] {
        var visited = Set<Int>()
        return getNodesInRange(ship: ship, visited: &visited, range: range, map: map)
    }

    func getCompletePath(to node: Node, map: Map) -> [Node] {
        var queue = [(self, [Node]())]
        var visited = Set<Int>()
        var next = self
        var path = [Node]()
        while (next != node && !queue.isEmpty) {
            (next, path) = queue.removeFirst()
            if visited.contains(next.identifier) {
                continue
            }
            visited.insert(next.identifier)
            for neighbor in map.getAllPaths() {
                queue.append((neighbor.toNode, path + [next]))
            }
        }
        guard next == node else {
            return [node]
        }
        return path
    }

    private func getNodesInRange(ship: Pirate_WeatherEntity, visited: inout Set<Int>, range: Double, map: Map) -> [Node] {
        var result = [Node]()
        guard range >= 0 else {
            return result
        }
        result.append(self)
        for path in map.getPaths(of: self) {
            let neighbour = path.toNode
            if visited.contains(neighbour.identifier) {
                continue
            }
            visited.insert(neighbour.identifier)
            let remainingMovement = range - path.computeCostOfPath(baseCost: 1, with: ship)
            result += neighbour.getNodesInRange(ship: ship, range: remainingMovement, map: map)
        }
        return result
    }
}
