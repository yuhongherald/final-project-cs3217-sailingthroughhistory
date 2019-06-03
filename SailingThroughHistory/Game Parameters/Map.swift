//
//  Map.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

/**
 * Model to store initial position of nodes, paths, objects.
 */
class Map: Codable {
    let basePirateRate = 0.03
    var map: String
    var bounds: Rect
    var nodeIDPair: [Int: Node]
    private(set) var gameObjects = GameVariable(value: [GameObject]())
    var npcs: [NPC] {
        return gameObjects.value
            .compactMap { $0 as? NPC }
    }
    var nodes = GameVariable(value: Set<Node>()) // need acces to nodes and paths
    private var pathsVariable = GameVariable(value: [Node: [Path]]())
    private var paths: [Node: [Path]] {
        set {
            pathsVariable.value = newValue
        }

        get {
            return pathsVariable.value
        }
    }

    init(map: String, bounds: Rect?) {
        guard let unwrappedBounds = bounds else {
            fatalError("Map bounds shouldn't be nil.")
        }
        self.map = map
        self.bounds = unwrappedBounds
        nodeIDPair = [Int: Node]()
    }

    /// Update weather information to the month.
    /// - Parameters:
    ///   - month: current month
    func updateWeather(for month: Int) {
        for path in paths.values.flatMap({ $0 }) {
            for weather in path.modifiers {
                weather.update(currentMonth: month)
            }
        }
    }

    /// Change map background.
    /// - Parameters:
    ///   - map: image name of the new background
    ///   - bounds: bounds of the new background
    func changeBackground(_ map: String, with bounds: Rect?) {
        guard let unwrappedBounds = bounds else {
            fatalError("Map bounds shouldn't be nil.")
        }
        self.map = map
        self.bounds = unwrappedBounds
    }

    /// Add node to the map. Map node id to the node.
    func addNode(_ node: Node) {
        nodes.value.insert(node)
        nodeIDPair[node.identifier] = node
    }

    /// Remove node from the map. Remove mapping from the node id to the node.
    func removeNode(_ node: Node) {
        assert(checkRep())
        nodes.value.remove(node)
        nodeIDPair.removeValue(forKey: node.identifier)

        // Remove all paths related with removed node
        guard let pathsOfNode = paths[node] else {
            return
        }
        for path in pathsOfNode {
            paths[path.toNode]?.removeAll(where: { $0 == path })
            paths[path.fromNode]?.removeAll(where: { $0 == path })
        }

        assert(checkRep())
    }

    /// Add path to the map. Path should be added to both fromNode and toNode.
    func add(path: Path) {
        assert(checkRep())
        guard nodes.value.contains(path.toNode) && nodes.value.contains(path.fromNode)
            && path.toNode != path.fromNode else {
            NSLog("\(path) is not added to map due to absense of its nodes")
            return
        }
        if paths[path.fromNode] == nil {
            paths[path.fromNode] = []
        }

        if paths[path.toNode] == nil {
            paths[path.toNode] = []
        }

        paths[path.fromNode]?.append(path)
        paths[path.toNode]?.append(path)
        assert(checkRep())
    }

    /// Remove path from the map.
    func removePath(_ path: Path) {
        pathsVariable.value[path.fromNode]?.removeAll(where: { $0 == path })
        pathsVariable.value[path.toNode]?.removeAll(where: { $0 == path })
    }

    /// Return all nodes in the map.
    func getNodes() -> Set<Node> {
        return nodes.value
    }

    /// Return all paths related to node.
    func getPaths(of node: Node) -> [Path] {
        return paths[node] ?? [Path]()
    }

    /// Return all paths in the map.
    func getAllPaths() -> Set<Path> {
        var pathSet = Set<Path>()

        for path in paths {
            path.value.forEach { pathSet.insert($0) }
        }

        return pathSet
    }

    /// Add gameobject to the map
    func addGameObject(gameObject: GameObject) {
        gameObjects.value.append(gameObject)
    }

    func subscribeToNodes(with callback: @escaping (Set<Node>) -> Void) {
        nodes.subscribe(with: callback)
    }

    func subscribeToPaths(with callback: @escaping ([Node: [Path]]) -> Void) {
        pathsVariable.subscribe(with: callback)
    }

    func subscribeToObjects(with callback: @escaping (([GameObject]) -> Void)) {
        gameObjects.subscribe(with: callback)
    }

    /// Get all pirates island in the map.
    func getPiratesIslands() -> [(Node, PirateIsland)] {
        return getNodes().map { node in
            node.objects
                .compactMap { $0 as? PirateIsland }
                .map { (node, $0) }
            }.flatMap { $0 }
    }

    /// Remove all NPCs in the map.
    func removeAllNpcs() {
        gameObjects.value = gameObjects
            .value
            .filter { $0 as? NPC == nil }
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        Node.nextID = try container.decode(Int.self, forKey: .nodeNextId)
        Node.reuseID = try container.decode([Int].self, forKey: .nodeReuseId)

        self.map = try container.decode(String.self, forKey: .map)
        self.bounds = try container.decode(Rect.self, forKey: .bounds)

        var nodesArrayForType = try container.nestedUnkeyedContainer(forKey: CodingKeys.nodes)
        var nodes = Set<Node>()
        nodeIDPair = [Int: Node]()
        while !nodesArrayForType.isAtEnd {
            let node = try nodesArrayForType.nestedContainer(keyedBy: NodeTypeKey.self)
            let type = try node.decode(NodeTypes.self, forKey: NodeTypeKey.type)

            switch type {
            case .port:
                let node = try node.decode(Port.self, forKey: NodeTypeKey.node)
                nodes.insert(node)
                nodeIDPair[node.identifier] = node
            case .sea:
                let node = try node.decode(Sea.self, forKey: NodeTypeKey.node)
                nodes.insert(node)
                nodeIDPair[node.identifier] = node
            }
        }
        self.nodes.value = nodes

        var simplifiedPaths = try container.nestedUnkeyedContainer(forKey: .paths)
        while !simplifiedPaths.isAtEnd {
            let simplifiedPath = try simplifiedPaths.nestedContainer(keyedBy: PathKeys.self)
            let fromId = try simplifiedPath.decode(Int.self, forKey: PathKeys.fromId)
            let toId = try simplifiedPath.decode(Int.self, forKey: PathKeys.toId)
            guard let fromNode = nodeIDPair[fromId], let toNode = nodeIDPair[toId] else {
                continue
            }

            var volatilesArrayForType = try simplifiedPath.nestedUnkeyedContainer(forKey: PathKeys.volatiles)
            var modifiers = [Volatile]()
            while !volatilesArrayForType.isAtEnd {
                let volatile = try volatilesArrayForType.nestedContainer(keyedBy: VolatileTypeKey.self)
                let type = try volatile.decode(VolatileTypes.self, forKey: VolatileTypeKey.type)

                switch type {
                case .volatileMonsoon:
                    let volatile = try volatile.decode(VolatileMonsoon.self, forKey: VolatileTypeKey.volatile)
                    modifiers.append(volatile)
                case .weather:
                    let volatile = try volatile.decode(Weather.self, forKey: VolatileTypeKey.volatile)
                    modifiers.append(volatile)
                }
            }

            let path = Path(from: fromNode, to: toNode)
            path.modifiers = modifiers

            if self.paths[fromNode] == nil {
                self.paths[fromNode] = []
            }
            if self.paths[toNode] == nil {
                self.paths[toNode] = []
            }
            self.paths[fromNode]?.append(path)
            self.paths[toNode]?.append(path)
        }

        self.pathsVariable.value = paths
        var objectsWithType = try container.nestedUnkeyedContainer(forKey: CodingKeys.objects)
        while !objectsWithType.isAtEnd {
            let object = try objectsWithType.nestedContainer(keyedBy: ObjectTypeKey.self)
            let type = try object.decode(ObjectType.self, forKey: .type)

            switch type {
            case .npc:
                let object = try object.decode(NPC.self, forKey: .object)
                addGameObject(gameObject: object)
            case .ship:
                let object = try object.decode(ShipUI.self, forKey: .object)
                addGameObject(gameObject: object)
            case .pirate:
                let object = try object.decode(PirateIsland.self, forKey: .object)
                addGameObject(gameObject: object)
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(map, forKey: .map)

        try container.encode(Node.nextID, forKey: .nodeNextId)
        try container.encode(Node.reuseID, forKey: .nodeReuseId)

        var nodesWithType = [NodeWithType]()
        for node in nodes.value {
            if node is Port {
                nodesWithType.append(NodeWithType(node: node, type: NodeTypes.port))
            }
            if node is Sea {
                nodesWithType.append(NodeWithType(node: node, type: NodeTypes.sea))
            }
        }
        try container.encode(nodesWithType, forKey: .nodes)

        var simplifiedPaths = [SimplifiedPath]()
        for pair in getAllPaths() {
            let fromID = pair.fromNode.identifier
            let toID = pair.toNode.identifier
            var volatileWithType = [VolatileWithType]()
            for volatile in pair.modifiers {
                if volatile is VolatileMonsoon {
                    volatileWithType.append(VolatileWithType(volatile: volatile, type: VolatileTypes.volatileMonsoon))
                }
                if volatile is Weather {
                    volatileWithType.append(VolatileWithType(volatile: volatile, type: VolatileTypes.weather))
                }
            }
            simplifiedPaths.append(SimplifiedPath(fromId: fromID, toId: toID, volatiles: volatileWithType))
        }
        try container.encode(simplifiedPaths, forKey: .paths)
        try container.encode(bounds, forKey: .bounds)
        try container.encode(nodesWithType, forKey: .nodes)
        var objectsWithType = [ObjectWithType]()
        for object in gameObjects.value {
            if object is ShipUI {
                continue
            } else if object is PirateIsland {
                objectsWithType.append(ObjectWithType(object: object, type: ObjectType.pirate))
            } else if object is NPC {
                objectsWithType.append(ObjectWithType(object: object, type: ObjectType.npc))
            }
        }
        try container.encode(objectsWithType, forKey: .objects)
    }

    enum CodingKeys: String, CodingKey {
        case map
        case nodes
        case paths
        case bounds
        case entities
        case nodeNextId
        case nodeReuseId
        case npcs
        case objects
    }

    enum NodeTypeKey: String, CodingKey {
        case type
        case node
    }

    enum NodeTypes: String, Codable {
        case port
        case sea
    }

    struct SimplifiedPath: Codable {
        var fromId: Int
        var toId: Int
        var volatiles: [VolatileWithType]

        init(fromId: Int, toId: Int, volatiles: [VolatileWithType]) {
            self.fromId = fromId
            self.toId = toId
            self.volatiles = volatiles
        }
    }

    enum PathKeys: String, CodingKey {
        case fromId
        case toId
        case volatiles
    }

    enum VolatileTypeKey: String, CodingKey {
        case type
        case volatile
    }

    enum VolatileTypes: String, Codable {
        case volatileMonsoon
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

    enum ObjectTypeKey: String, CodingKey {
        case type
        case object
    }

    enum ObjectType: String, Codable {
        case npc
        case pirate
        case ship
    }

    struct NodeWithType: Codable, Hashable {
        var node: Node
        var type: NodeTypes

        init(node: Node, type: NodeTypes) {
            self.node = node
            self.type = type
        }
    }

    struct ObjectWithType: Codable {
        let object: GameObject
        let type: ObjectType
    }

    private func checkRep() -> Bool {
        for path in getAllPaths() {
            guard nodes.value.contains(path.toNode) && nodes.value.contains(path.fromNode) else {
                return false
            }
            guard path.toNode != path.fromNode else {
                return false
            }
        }

        for node in nodes.value {
            guard nodeIDPair[node.identifier] != nil else {
                return false
            }
        }

        for node in nodeIDPair.values {
            guard nodes.value.contains(node) else {
                return false
            }
        }

        return true
    }
}
