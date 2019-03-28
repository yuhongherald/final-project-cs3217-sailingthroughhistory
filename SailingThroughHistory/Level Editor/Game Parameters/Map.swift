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
    private var nodes = Set<Node>()
    private var paths = [GameObject: [Path]]()

    func addMap(_ map: String) {
        self.map = map
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
                if path.toObject == node || path.fromObject == node {
                    pathArr.remove(at: index)
                }
            }
        }
    }

    func add(path: Path) {
        if paths[path.fromObject] == nil {
            paths[path.fromObject] = []
        }

        if paths[path.toObject] == nil {
            paths[path.toObject] = []
        }

        paths[path.fromObject]?.append(path)
        paths[path.toObject]?.append(path)
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
        for node in nodes where node.frame.originX == Double(point.x) &&
            node.frame.originY == Double(point.y) {
            return node
        }
        return nil
    }

    init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.map = try container.decode(String.self, forKey: .map)

        var nodesArrayForType = try container.nestedUnkeyedContainer(forKey: CodingKeys.nodes)
        var nodes = Set<Node>()
        while !nodesArrayForType.isAtEnd {
            let node = try nodesArrayForType.nestedContainer(keyedBy: NodeTypeKey.self)
            let type = try node.decode(NodeTypes.self, forKey: NodeTypeKey.type)

            switch type {
            case .port:
                nodes.insert(try node.decode(Port.self, forKey: NodeTypeKey.node))
            case .sea:
                nodes.insert(try node.decode(Sea.self, forKey: NodeTypeKey.node))
            case .pirate:
                nodes.insert(try node.decode(Pirate.self, forKey: NodeTypeKey.node))
            }
        }
        self.nodes = nodes

        self.paths = try container.decode([GameObject: [Path]].self, forKey: .paths)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(map, forKey: .map)

        var nodesWithType = [NodeWithType]()
        for node in nodes {
            if node is Port {
                nodesWithType.append(NodeWithType(node: node, type: NodeTypes.port))
            }
            if node is Sea {
                nodesWithType.append(NodeWithType(node: node, type: NodeTypes.sea))
            }
            if node is Pirate {
                nodesWithType.append(NodeWithType(node: node, type: NodeTypes.pirate))
            }
        }
        try container.encode(nodesWithType, forKey: .nodes)

        var simplifiedPaths = [GameObject: [Path]]()
        for pair in paths {
            let key = GameObject(image: pair.key.image, frame: pair.key.frame)
            simplifiedPaths[key] = pair.value
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
    }

    enum NodeTypes: String, Codable {
        case port
        case sea
        case pirate
    }

    struct NodeWithType: Codable {
        var node: Node
        var type: NodeTypes
        init(node: Node, type: NodeTypes) {
            self.node = node
            self.type = type
        }
    }
}
