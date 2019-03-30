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
    private var nodes = Set<Node>()
    private var paths = [Node: [Path]]()
    private var bounds: Rect

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
        nodes.insert(node)
    }

    func removeNode(_ node: Node) {
        nodes.remove(node)

        // Remove all paths related with removed node
        for nodePath in paths {
            var pathArr = nodePath.value
            for (index, path) in pathArr.enumerated() {
                if path.toNode == node || path.fromNode == node {
                    pathArr.remove(at: index)
                }
            }
        }
    }

    func add(path: Path) {
        if paths[path.fromNode] == nil {
            paths[path.fromNode] = []
        }

        if paths[path.toNode] == nil {
            paths[path.toNode] = []
        }

        paths[path.fromNode]?.append(path)
        paths[path.toNode]?.append(path)
    }

    func getNodes() -> Set<Node> {
        return nodes
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
        for node in nodes where node.frame.origin.x == point.x &&
            node.frame.origin.y == point.y {
            return node
        }
        return nil
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.map = try container.decode(String.self, forKey: .map)

        var nodesArrayForType = try container.nestedUnkeyedContainer(forKey: CodingKeys.nodes)
        var nodes = Set<Node>()
        while !nodesArrayForType.isAtEnd {
            var nodeIDPair = [Int: Node]()
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
        self.nodes = nodes

        self.paths = try container.decode([Node: [Path]].self, forKey: .paths)
        self.bounds = try container.decode(Rect.self, forKey: .bounds)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(map, forKey: .map)

        var nodesWithType = [NodeWithType]()
        var nodeIDPair = [Node: Int]()
        for (identifier, node) in nodes.enumerated() {
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

        var simplifiedPaths = [Int: Int]()
        for pair in getAllPaths() {
            guard let fromID = nodeIDPair[pair.fromNode],
            let toID = nodeIDPair[pair.toNode] else {
                continue
            }
            simplifiedPaths[fromID] = toID
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
}
