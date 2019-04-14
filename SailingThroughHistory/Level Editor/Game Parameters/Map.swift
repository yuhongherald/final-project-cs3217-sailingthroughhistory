//
//  Map.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Map: Codable {
    let basePirateRate = 0.03
    var map: String
    var bounds: Rect
    var nodeIDPair: [Int: Node]
    private(set) var gameObjects = GameVariable(value: [GameObject]())
    var npcs = [NPC]()
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

    func changeBackground(_ map: String, with bounds: Rect?) {
        guard let unwrappedBounds = bounds else {
            fatalError("Map bounds shouldn't be nil.")
        }
        self.map = map
        self.bounds = unwrappedBounds
    }

    func addNode(_ node: Node) {
        nodes.value.insert(node)
        nodeIDPair[node.identifier] = node
    }

    func removeNode(_ node: Node) {
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

    func add(path: Path) {
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

    func removePath(_ path: Path) {
        pathsVariable.value[path.fromNode]?.removeAll(where: { $0 == path })
        pathsVariable.value[path.toNode]?.removeAll(where: { $0 == path })
    }

    func getNodes() -> Set<Node> {
        return nodes.value
    }

    func getPaths(of node: Node) -> [Path] {
        return paths[node] ?? [Path]()
    }

    func getAllPaths() -> Set<Path> {
        var pathSet = Set<Path>()

        for path in paths {
            path.value.forEach { pathSet.insert($0) }
        }

        return pathSet
    }

    func findNode(at point: CGPoint) -> Node? {
        for node in nodes.value where CGFloat(node.frame.originX) == point.x &&
            CGFloat(node.frame.originY) == point.y {
            return node
        }
        return nil
    }

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

    func getPiratesIslands() -> [(Node, PirateIsland)] {
        return getNodes().map { node in
            node.objects
                .compactMap { $0 as? PirateIsland }
                .map { (node, $0) }
            }.flatMap { $0 }
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        Node.nextID = try container.decode(Int.self, forKey: .nodeNextId)
        Node.reuseID = try container.decode([Int].self, forKey: .nodeReuseId)
        print(Node.nextID)

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

        let pathDictionary = try container.decode([Int: [Int: [Volatile]]].self, forKey: .paths)
        for pair in pathDictionary {
            guard let fromNode = nodeIDPair[pair.key] else {
                continue
            }
            for subPair in pair.value {
                guard let toNode = nodeIDPair[subPair.key] else {
                    continue
                }

                // add path to from node neighbour
                if paths[fromNode] == nil {
                    paths[fromNode] = []
                }
                let path = Path(from: fromNode, to: toNode)
                path.modifiers = subPair.value
                paths[fromNode]?.append(path)

                // add path to to node neighbour
                if paths[toNode] == nil {
                    paths[toNode] = []
                }
                paths[toNode]?.append(path)
            }
        }
        self.pathsVariable.value = paths
        self.npcs = try container.decode([NPC].self, forKey: .npcs)
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

        var simplifiedPaths = [Int: [Int: [Volatile]]]()

        for pair in getAllPaths() {
            let fromID = pair.fromNode.identifier
            let toID = pair.toNode.identifier
            if simplifiedPaths[fromID] == nil {
                simplifiedPaths[fromID] = [:]
            }
            simplifiedPaths[fromID]?[toID] = []
            pair.modifiers.forEach { simplifiedPaths[fromID]?[toID]?.append($0)}
        }

        try container.encode(simplifiedPaths, forKey: .paths)
        try container.encode(bounds, forKey: .bounds)
        try container.encode(nodesWithType, forKey: .nodes)
        try container.encode(npcs, forKey: .npcs)
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
    }

    enum NodeTypeKey: String, CodingKey {
        case type
        case node
    }

    enum NodeTypes: String, Codable {
        case port
        case sea
    }

    enum EntityTypeKey: String, CodingKey {
        case type
        case entity
    }

    enum EntityTypes: String, Codable {
        case pirate
        case npc
    }

    struct NodeWithType: Codable, Hashable {
        var node: Node
        var type: NodeTypes

        init(node: Node, type: NodeTypes) {
            self.node = node
            self.type = type
        }
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
