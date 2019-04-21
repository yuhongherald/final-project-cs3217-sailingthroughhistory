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
    var node1 = NodeStub(name: "testNode1", identifier: 99)
    var node2 = NodeStub(name: "testNode2", identifier: 100)
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
        map.addNode(node1)
        map.addNode(node2)
        port1.taxAmount.value = 0
        port2.taxAmount.value = 1000
        port3.taxAmount.value = 2000

        map.add(path: Path(from: port2, to: port1))
        map.add(path: Path(from: port1, to: port2))
        map.add(path: Path(from: port1, to: node1))
        map.add(path: Path(from: node1, to: port1))
        map.add(path: Path(from: node1, to: node2))
        map.add(path: Path(from: node2, to: node1))
        map.add(path: Path(from: node2, to: port3))
        map.add(path: Path(from: port3, to: node2))
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

        let npc = NPC(node: node1, maxTaxAmount: 1)
        XCTAssertEqual(npc.nodeId, node1.identifier)
        XCTAssertEqual(npc.identifier, 0)
        XCTAssertEqual(npc.maxTaxAmount, 1)
        XCTAssertEqual(npc.nextSeed, npc.identifier)
        XCTAssertEqual(npc.nextDestinationId, node1.identifier)
    }

    func testNPCEncodeDecode() {
        NPC.nextId = 0

        let npc = NPC(node: node1, maxTaxAmount: 1)
        guard let npcEncoded = try? JSONEncoder().encode(npc) else {
            XCTFail("Encode failed")
            return
        }
        guard let npcDecoded = try? JSONDecoder().decode(NPC.self, from: npcEncoded) else {
            XCTFail("Decode failed")
            return
        }
        XCTAssertEqual(npcDecoded.nodeId, node1.identifier)
        XCTAssertEqual(npcDecoded.identifier, 0)
        XCTAssertEqual(npc.maxTaxAmount, 1)
        XCTAssertEqual(npcDecoded.nextSeed, npc.identifier)
        XCTAssertEqual(npcDecoded.nextDestinationId, node1.identifier)
    }

    func testNPCMoveToNextNode() {
        let npc1 = NPC(node: port2, maxTaxAmount: maxTaxAmount)
        npc1.nextSeed = 1000
        npc1.nextDestinationId = node1.identifier
        guard let result1 = npc1.moveToNextNode(map: map) else {
            XCTFail("NPC failed to move")
            return
        }
        XCTAssertEqual(result1, node1)

        let npc2 = NPC(node: port1, maxTaxAmount: maxTaxAmount)
        npc2.nextDestinationId = port3.identifier
        let team = Team(name: "testTeam")
        port3.owner = team
        guard let result2 = npc2.moveToNextNode(map: map) else {
            XCTFail("NPC failed to move")
            return
        }
        XCTAssertEqual(result2, port3)
        XCTAssertEqual(team.money.value, port3.taxAmount.value)
        port3.owner = nil
    }

    func testGetNextNode() {
        map.removeNode(port3)

        let npc1 = NPC(node: port1, maxTaxAmount: maxTaxAmount)
        _ = npc1.getNextNode(map: map)
        XCTAssertEqual(npc1.nextDestinationId, port2.identifier)

        let npc2 = NPC(node: node1, maxTaxAmount: maxTaxAmount)
        npc2.nextDestinationId = port1.identifier
        XCTAssertEqual(npc2.getNextNode(map: map), port1.identifier)
    }

}
