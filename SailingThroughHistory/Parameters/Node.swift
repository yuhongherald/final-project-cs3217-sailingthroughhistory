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
    static var reuseID: [Int] = []
    let identifier: Int
    let name: String
    let frame: Rect
    var objects: [GameObject] = []

    init(name: String, frame: Rect) {
        self.name = name
        self.frame = frame
        if (!Node.reuseID.isEmpty) {
            self.identifier = Node.reuseID.removeLast()
        } else {
            self.identifier = Node.nextID
            Node.nextID += 1
        }
    }

    func remove() {
        Node.reuseID.append(self.identifier)
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
        var pq = PriorityQueue<ComparablePair<Node>>()
        var visited = Set<Int>()
        var next = self
        var nodesInRange = [Node]()
        pq.add(ComparablePair(object: next, weight: 0))
        while !pq.isEmpty {
            let comparableNode = pq.poll()
            let weight = comparableNode?.weight ?? 0
            next = comparableNode?.object ?? self
            if visited.contains(next.identifier) || weight > range {
                continue
            }
            visited.insert(next.identifier)
            nodesInRange.append(next)
            for neighbor in map.getPaths(of: next) {
                let cost = neighbor.computeCostOfPath(baseCost: 1, with: ship)
                pq.add(ComparablePair<Node>(object: neighbor.toNode, weight: weight + cost))
            }
        }
        return nodesInRange
    }

    func getCompleteShortestPath(to node: Node, with ship: Pirate_WeatherEntity, map: Map) -> [Node] {
        var pq = PriorityQueue<ComparablePair<[Node]>>()
        var visited = Set<Int>()
        var next = self
        var path = [Node]()
        pq.add(ComparablePair(object: [next], weight: 0))
        while next != node && !pq.isEmpty {
            let comparablePath = pq.poll()
            path = comparablePath?.object ?? [self]
            let weight = comparablePath?.weight ?? 0
            next = path.last ?? self
            if visited.contains(next.identifier) {
                continue
            }
            visited.insert(next.identifier)
            for neighbor in map.getPaths(of: next) {
                let cost = neighbor.computeCostOfPath(baseCost: 1, with: ship)
                pq.add(ComparablePair<[Node]>(object: path + [neighbor.toNode], weight: weight + cost))
            }
        }
        return path
    }
}
