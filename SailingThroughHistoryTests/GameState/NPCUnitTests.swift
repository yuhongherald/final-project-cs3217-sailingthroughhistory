//
//  NPCUnitTests.swift
//  SailingThroughHistoryTests
//
//  Created by henry on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class NPCUnitTests: XCTestCase {
    let maxTaxAmount = 2000
    var node = NodeStub(name: "testNode", identifier: 99)
    var port1 = PortStub()
    var port2 = PortStub()
    var port3 = PortStub()
    var map = Map(map: "testMap", bounds: Rect(originX: 0, originY: 0, height: 0, width: 0))

    override func setUp() {
        super.setUp()
        Node.nextID = 0
        Node.reuseID.removeAll()
        map = Map(map: "testMap", bounds: Rect(originX: 0, originY: 0, height: 0, width: 0))
        map.addNode(port1)
        map.addNode(port2)
        map.addNode(port3)
        port1.taxAmount.value = 0
        port2.taxAmount.value = 500
        port3.taxAmount.value = 1000

        map.add(path: Path(from: port1, to: port2))
        map.add(path: Path(from: port2, to: port1))
        map.add(path: Path(from: port1, to: port3))
        map.add(path: Path(from: port3, to: port1))
        map.add(path: Path(from: port2, to: port3))
        map.add(path: Path(from: port3, to: port2))
    }

    override class func tearDown() {
        Node.nextID = 0
        Node.reuseID.removeAll()
        NPC.nextId = 0
    }

    override func tearDown() {
        for node in map.nodes.value {
            map.removeNode(node)
        }
    }

    func testNPCConstructor() {
        NPC.nextId = 0

        let npc = NPC(node: node, maxTaxAmount: 1)
        XCTAssertEqual(npc.nodeId, node.identifier)
        XCTAssertEqual(npc.identifier, 0)
        XCTAssertEqual(npc.maxTaxAmount, 1)
        XCTAssertEqual(npc.nextSeed, npc.identifier)
        XCTAssertEqual(npc.nextDestinationId, node.identifier)
    }

    func testNPCEncodeDecode() {
        NPC.nextId = 0

        let npc = NPC(node: node, maxTaxAmount: 1)
        guard let npcEncoded = try? JSONEncoder().encode(npc) else {
            XCTFail("Encode failed")
            return
        }
        guard let npcDecoded = try? JSONDecoder().decode(NPC.self, from: npcEncoded) else {
            XCTFail("Decode failed")
            return
        }
        XCTAssertEqual(npcDecoded.nodeId, node.identifier)
        XCTAssertEqual(npcDecoded.identifier, 0)
        XCTAssertEqual(npc.maxTaxAmount, 1)
        XCTAssertEqual(npcDecoded.nextSeed, npc.identifier)
        XCTAssertEqual(npcDecoded.nextDestinationId, node.identifier)
    }

    func testNPCMoveToNextNode() {
        let npc = NPC(node: port1, maxTaxAmount: 1000)
        /*
        func moveToNextNode(map: Map, maxTaxAmount: Int) -> Node? {
            let nextNodeId = getNextNode(map: map, maxTaxAmount: maxTaxAmount)
            guard let currentNode = map.nodeIDPair[nodeId], let nextNode = map.nodeIDPair[nodeId] else {
                return nil
            }
            nodeId = nextNodeId
            let path = currentNode.getCompleteShortestPath(to: nextNode, with: self, map: map)
            for node in path {
                frame.value = node.frame
            }
            frame.value = nextNode.frame
            if let port = nextNode as? Port {
                port.collectTax(from: self)
            }
            return nextNode
        }*/
    }

    func testGetNextNode() {
        /*func getNextNode(map: Map, maxTaxAmount: Int) -> Int {
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
         }*/
    }

}
