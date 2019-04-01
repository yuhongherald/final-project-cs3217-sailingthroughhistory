//
//  Map.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Map: Codable {
    var map: String
    var bounds: Rect
    private var nodes = GameVariable(value: Set<Node>())
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
    }

    func removeNode(_ node: Node) {
        nodes.value.remove(node)

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
        guard nodes.value.contains(path.toNode) && nodes.value.contains(path.fromNode) else {
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

    func subscribeToNodes(with callback: @escaping (Set<Node>) -> Void) {
        nodes.subscribe(with: callback)
    }

    func subscribeToPaths(with callback: @escaping ([Node: [Path]]) -> Void) {
        pathsVariable.subscribe(with: callback)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.map = try container.decode(String.self, forKey: .map)
        self.bounds = try container.decode(Rect.self, forKey: .bounds)

        var nodesArrayForType = try container.nestedUnkeyedContainer(forKey: CodingKeys.nodes)
        var nodes = Set<Node>()
        var nodeIDPair = [Int: Node]()
        while !nodesArrayForType.isAtEnd {
            let node = try nodesArrayForType.nestedContainer(keyedBy: NodeTypeKey.self)
            let type = try node.decode(NodeTypes.self, forKey: NodeTypeKey.type)
            let identifier = try node.decode(Int.self, forKey: .identifier)

            switch type {
            case .port:
                let node = try node.decode(Port.self, forKey: NodeTypeKey.node)
                nodes.insert(node)
                nodeIDPair[identifier] = node
            case .sea:
                let node = try node.decode(Sea.self, forKey: NodeTypeKey.node)
                nodes.insert(node)
                nodes.insert(node)
                nodeIDPair[identifier] = node
            case .pirate:
                let node = try node.decode(Pirate.self, forKey: NodeTypeKey.node)
                nodes.insert(node)
                nodes.insert(node)
                nodeIDPair[identifier] = node
            }
        }
        self.nodes.value = nodes

        let pathDictionary = try container.decode([Int: [Int]].self, forKey: .paths)
        for pair in pathDictionary {
            guard let fromNode = nodeIDPair[pair.key] else {
                continue
            }
            if paths[fromNode] == nil {
                paths[fromNode] = []
            }
            for toID in pair.value {
                guard let toNode = nodeIDPair[toID] else {
                    continue
                }
                paths[fromNode]?.append(Path(from: fromNode, to: toNode))
                if paths[toNode] == nil {
                    paths[toNode] = []
                }
                paths[toNode]?.append(Path(from: toNode, to: fromNode))
            }
        }
        self.pathsVariable.value = paths
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(map, forKey: .map)

        var nodesWithType = [NodeWithType]()
        var nodeIDPair = [Node: Int]()
        for (identifier, node) in nodes.value.enumerated() {
            if node is Port {
                nodesWithType.append(NodeWithType(identifier: identifier, node: node, type: NodeTypes.port))
                nodeIDPair[node] = identifier
            }
            if node is Sea {
                nodesWithType.append(NodeWithType(identifier: identifier, node: node, type: NodeTypes.sea))
                nodeIDPair[node] = identifier
            }
            if node is Pirate {
                nodesWithType.append(NodeWithType(identifier: identifier, node: node, type: NodeTypes.pirate))
                nodeIDPair[node] = identifier
            }
        }
        try container.encode(nodesWithType, forKey: .nodes)

        var simplifiedPaths = [Int: [Int]]()
        for pair in getAllPaths() {
            guard let fromID = nodeIDPair[pair.fromNode],
                let toID = nodeIDPair[pair.toNode] else {
                    continue
            }
            if simplifiedPaths[fromID] == nil {
                simplifiedPaths[fromID] = []
            }
            simplifiedPaths[fromID]?.append(toID)
        }
        try container.encode(simplifiedPaths, forKey: .paths)
        try container.encode(bounds, forKey: .bounds)
    }

    enum CodingKeys: String, CodingKey {
        case map
        case nodes
        case paths
        case bounds
    }

    enum NodeTypeKey: String, CodingKey {
        case type
        case node
        case identifier
    }

    enum NodeTypes: String, Codable {
        case port
        case sea
        case pirate
    }

    struct NodeWithType: Codable, Hashable {
        var node: Node
        var type: NodeTypes
        var identifier: Int

        init(identifier: Int, node: Node, type: NodeTypes) {
            self.identifier = identifier
            self.node = node
            self.type = type
        }
    }

    private func checkRep() -> Bool {
        for path in getAllPaths() {
            guard nodes.value.contains(path.toNode) && nodes.value.contains(path.fromNode) else {
                return false
            }
        }
        return true
    }
}
