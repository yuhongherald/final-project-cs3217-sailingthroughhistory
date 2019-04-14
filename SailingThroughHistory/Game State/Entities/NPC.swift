//
//  NPC.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation
import GameKit

class NPC: GameObject {
    private static let NPCNodeHeight: Double = 50
    private static let NPCNodeWidth: Double = 50

    private (set) static var nextId: UInt = 0
    private static var reuseIds = [UInt]()

    let numDieSides = 12
    let identifier: UInt
    var nodeId: Int
    var nextSeed: UInt
    var nextDestinationId: Int

    required init(node: Node) {
        nodeId = node.identifier
        identifier = NPC.getNextId()
        nextSeed = identifier
        nextDestinationId = nodeId
        super.init(frame: node.frame)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nodeId = try values.decode(Int.self, forKey: .nodeId)
        identifier = try values.decode(UInt.self, forKey: .identifier)
        nextSeed = try values.decode(UInt.self, forKey: .nextSeed)
        nextDestinationId = try values.decode(Int.self, forKey: .nextDestinationId)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodeId, forKey: .nodeId)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(nextSeed, forKey: .nextSeed)
        try container.encode(nextDestinationId, forKey: .nextDestinationId)

        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }

    private enum CodingKeys: String, CodingKey {
        case nodeId
        case identifier
        case nextSeed
        case nextDestinationId
    }

    func remove() {
        NPC.reuseIds.append(identifier)
    }

    func moveToNextNode(map: Map, maxTaxAmount: Int) -> [Node] {
        let nextNodeId = getNextNode(map: map, maxTaxAmount: maxTaxAmount)
        guard let currentNode = map.nodeIDPair[nodeId], let nextNode = map.nodeIDPair[nodeId] else {
            return []
        }
        nodeId = nextNodeId
        frame.value = nextNode.frame
        let path = currentNode.getCompleteShortestPath(to: nextNode, with: self, map: map)
        if let port = nextNode as? Port {
            port.collectTax(from: self)
        }
        return path
    }

    func getNextNode(map: Map, maxTaxAmount: Int) -> Int {
        var generator = GKMersenneTwisterRandomSource()
        generator.seed = UInt64(nextSeed)
        if nextDestinationId == nodeId {
            nextDestinationId = getNewDestinationPortId(generator: &generator, map: map)
        }
        guard let currentNode = map.nodeIDPair[nodeId] else {
            fatalError("NPC ship is in invalid node")
        }
        guard let destinationNode = map.nodeIDPair[nextDestinationId] else {
            fatalError("NPC ship has invalid destination node")
        }
        let path = currentNode.getCompleteShortestPath(to: destinationNode, with: self, map: map)
        let movementRoll = 1 + generator.nextInt(upperBound: numDieSides)

        if movementRoll >= path.count - 1 {
            nextSeed = UInt(generator.nextInt(upperBound: Int.max))
            return nextDestinationId
        }
        let selectedPorts = Array(path[0..<movementRoll]).map({ $0 as? Port }).compactMap({ $0 })
        var lowestTax = maxTaxAmount
        var lowestTaxPort = selectedPorts.first
        for port in selectedPorts {
            lowestTax = min(lowestTax, port.taxAmount.value)
            lowestTaxPort = port
        }

        let decidingRoll = generator.nextUniform()
        nextSeed = UInt(generator.nextInt(upperBound: Int.max))
        if decidingRoll > Float(lowestTax) / Float(maxTaxAmount),
            let lowestTaxPortId = lowestTaxPort?.identifier {
            return lowestTaxPortId
        }
        return path[movementRoll - 1].identifier
    }

    private static func getNextId() -> UInt {
        guard !reuseIds.isEmpty else {
            nextId += 1
            return nextId - 1
        }
        return reuseIds.removeFirst()
    }

    private func getNewDestinationPortId(generator: inout GKMersenneTwisterRandomSource, map: Map) -> Int {
        let ports = map.getNodes().map({ $0 as? Port }).compactMap({ $0 })
        let index = generator.nextInt(upperBound: ports.count)
        return ports[index].identifier
    }
}

extension NPC: Pirate_WeatherEntity {
    func startPirateChase() {
        fatalError("Not supported")
    }

    func getWeatherModifier() -> Double {
        return 1.0
    }
}
