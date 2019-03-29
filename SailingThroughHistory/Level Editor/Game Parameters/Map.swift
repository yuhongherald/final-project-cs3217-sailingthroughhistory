//
//  Map.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Map: Codable {
    var map = "worldmap1815"
    private var nodes = GameVariable(value: Set<Node>())
    private var paths = [Node: [Path]]()

    func addMap(_ map: String) {
        self.map = map
    }

    func addNode(_ node: Node) {
        nodes.value.insert(node)
    }

    func removeNode(_ node: Node) {
        nodes.value.remove(node)

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

    init() {}

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
        self.nodes.value = nodes

        self.paths = try container.decode([Node: [Path]].self, forKey: .paths)
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

        var simplifiedPaths = [Int: Int]()
        for pair in getAllPaths() {
            guard let fromID = nodeIDPair[pair.fromNode],
            let toID = nodeIDPair[pair.toNode] else {
                continue
            }
            simplifiedPaths[fromID] = toID
        }
        try container.encode(simplifiedPaths, forKey: .paths)
    }

    enum CodingKeys: String, CodingKey {
        case map
        case nodes
        case paths
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
