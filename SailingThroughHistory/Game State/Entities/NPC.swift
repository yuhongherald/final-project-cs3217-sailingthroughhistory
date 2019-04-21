//
//  NPC.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// An implementation of a Non-Player Controlled ship. This ship does not support the
/// usual operations of a normal ship and is primarily used to represent a GameObject
/// that objectively moves between ports, paying taxes to the owner whenever they stop
/// at a port. They do not have actual money, do not buy/sell items and has a higher
/// probability of stopping at a port with lower taxes.

/// Assumes that there are at least 2 ports on the given map, and all ports are
/// connected and accessible.
import Foundation
import GameKit

class NPC: GameObject {
    static var nextId: UInt = 0
    static var reuseIds = [UInt]()

    let numDieSides = 12
    let identifier: UInt
    let maxTaxAmount: Int
    var nodeId: Int
    var nextSeed: UInt
    var nextDestinationId: Int

    required init(node: Node, maxTaxAmount: Int) {
        nodeId = node.identifier
        identifier = NPC.getNextId()
        self.maxTaxAmount = maxTaxAmount
        nextSeed = identifier
        nextDestinationId = nodeId
        super.init(frame: node.frame)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nodeId = try values.decode(Int.self, forKey: .nodeId)
        identifier = try values.decode(UInt.self, forKey: .identifier)
        maxTaxAmount = try values.decode(Int.self, forKey: .maxTaxAmount)
        nextSeed = try values.decode(UInt.self, forKey: .nextSeed)
        nextDestinationId = try values.decode(Int.self, forKey: .nextDestinationId)
        let superDecoder = try values.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodeId, forKey: .nodeId)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(maxTaxAmount, forKey: .maxTaxAmount)
        try container.encode(nextSeed, forKey: .nextSeed)
        try container.encode(nextDestinationId, forKey: .nextDestinationId)

        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }

    private enum CodingKeys: String, CodingKey {
        case nodeId
        case identifier
        case maxTaxAmount
        case nextSeed
        case nextDestinationId
    }

    func remove() {
        NPC.reuseIds.append(identifier)
    }

    func moveToNextNode(map: Map) -> Node? {
        let nextNodeId = getNextNode(map: map)
        guard let currentNode = map.nodeIDPair[nodeId], let nextNode = map.nodeIDPair[nextNodeId] else {
            return nil
        }
        let path = currentNode.getCompleteShortestPath(to: nextNode, with: self, map: map)
        for node in path {
            frame.value = node.frame
        }
        frame.value = nextNode.frame
        nodeId = nextNodeId
        if let port = nextNode as? Port {
            port.collectTax(from: self)
        }
        return nextNode
    }

    func getNextNode(map: Map) -> Int {
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
            .filter({ $0.identifier != nextDestinationId })
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
