//
//  Node.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

/**
 * Model for node to store identifier, name, frame and objects in a node.
 */
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
        if !Node.reuseID.isEmpty {
            self.identifier = Node.reuseID.removeLast()
        } else {
            self.identifier = Node.nextID
            Node.nextID += 1
        }
    }

    /// Indicate removal of a node to reuse its identifier.
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
                let object = try object.decode(PirateIsland.self, forKey: ObjectTypeKey.object)
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
            if object is PirateIsland {
                objectsWithType.append(ObjectWithType(object: object, type: ObjectTypes.pirate))
            }
            if object is ShipUI {
                objectsWithType.append(ObjectWithType(object: object, type: ObjectTypes.shipUI))
            }
        }
        try container.encode(objectsWithType, forKey: .objects)
    }

    /// Add game object into the node.
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

    /// Get nodes that can be acheived from the node.
    /// - Parameters:
    ///   - ship: ship that requires the acheivable nodes
    ///   - range: range that that can be achieved from the node
    ///   - map: map contains the node
    /// - Returns:
    ///   The nodes that can be acheieved from the node.
    func getNodesInRange(ship: Pirate_WeatherEntity, range: Double, map: Map) -> [Node] {
        var pQueue = PriorityQueue<ComparablePair<Node>>()
        var visited = Set<Int>()
        var next = self
        var nodesInRange = [Node]()
        pQueue.add(ComparablePair(object: next, weight: 0))
        while !pQueue.isEmpty {
            let comparableNode = pQueue.poll()
            let weight = comparableNode?.weight ?? 0
            next = comparableNode?.object ?? self
            if visited.contains(next.identifier) || weight > range {
                continue
            }
            visited.insert(next.identifier)
            nodesInRange.append(next)
            for neighbor in map.getPaths(of: next) {
                let cost = neighbor.computeCostOfPath(baseCost: 1, with: ship)
                pQueue.add(ComparablePair<Node>(object: neighbor.toNode, weight: weight + cost))
            }
        }
        return nodesInRange
    }

    /// Get shortest path to another node.
    /// - Parameters:
    ///   - node: destination node
    ///   - ship: ship that requires the path
    ///   - map: map that contains the nodes
    /// - Returns:
    ///   The nodes on the shortest path.
    func getCompleteShortestPath(to node: Node, with ship: Pirate_WeatherEntity, map: Map) -> [Node] {
        var pQueue = PriorityQueue<ComparablePair<[Node]>>()
        var visited = Set<Int>()
        var next = self
        var path = [Node]()
        pQueue.add(ComparablePair(object: [next], weight: 0))
        while next != node && !pQueue.isEmpty {
            let comparablePath = pQueue.poll()
            path = comparablePath?.object ?? [self]
            let weight = comparablePath?.weight ?? 0
            next = path.last ?? self
            if visited.contains(next.identifier) {
                continue
            }
            visited.insert(next.identifier)
            for neighbor in map.getPaths(of: next) {
                let cost = neighbor.computeCostOfPath(baseCost: 1, with: ship)
                pQueue.add(ComparablePair<[Node]>(object: path + [neighbor.toNode], weight: weight + cost))
            }
        }
        return path.map { $0 }
    }

    /// Get num of nodes to the destination node.
    /// - Parameters:
    ///   - node: destination node
    ///   - map: map contains the nodes
    func getNumNodesTo(to node: Node, map: Map) -> Int? {
        var queue = [(Node, Int)]()
        var visited = Set<Int>()
        var next = self
        queue.append((next, 0))
        var weight = 0
        while next != node && !queue.isEmpty {
            (next, weight) = queue.removeFirst()
            if visited.contains(next.identifier) {
                continue
            }
            visited.insert(next.identifier)
            for neighbor in map.getPaths(of: next) {
                queue.append((neighbor.toNode, weight + 1))
            }
        }
        return next != node ? nil : weight
    }
}

extension Node: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }

    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
