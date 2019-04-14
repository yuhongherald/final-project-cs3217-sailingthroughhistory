//
//  NodeTest.swift
//  SailingThroughHistoryTests
//
//  Created by ysq on 4/13/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class NodeTest: XCTestCase {
    var sea: Sea = Sea(name: "sea", originX: 0, originY: 0)
    var pirateSea: Sea = {
        let sea = Sea(name: "pirateSea", originX: 100, originY: 100)
        sea.add(object: PirateIsland(in: sea))
        return sea
    }()
    var NPCport: SailingThroughHistory.Port = Port(team: nil, name: "port", originX: 20, originY: 20)
    var selfport: SailingThroughHistory.Port = Port(team: Team(name: "testTeam"), originX: 40, originY: 40)

    override func setUp() {
        Node.nextID = 0
        Node.reuseID = []
        sea = Sea(name: "sea", originX: 0, originY: 0)
        pirateSea = Sea(name: "pirateSea", originX: 100, originY: 100)
        let pirate = PirateIsland(in: pirateSea)
        pirateSea.add(object: pirate)
        NPCport = Port(team: nil, name: "port", originX: 20, originY: 20)
        selfport = Port(team: Team(name: "testTeam"), originX: 40, originY: 40)
    }

    func testUpdateNode() {
        let sea = Sea(name: "pirateSea", originX: 100, originY: 100)
        let objects = [PirateIsland(in: sea), PirateIsland(in: sea)]
        objects.forEach { sea.add(object: $0) }
        XCTAssertEqual(sea.objects, objects, "Objects update failed.")
    }

    func testCodableSea() {
        guard let encode = try? JSONEncoder().encode(sea) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(Sea.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertEqual(sea, decode, "Decode result is different from original one")
    }

    func testCodableSeaWithObjects() {
        guard let encode = try? JSONEncoder().encode(pirateSea) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(Sea.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertEqual(pirateSea, decode, "Decode result is different from original one")
    }

    func testCodableNPCPort() {
        guard let encode = try? JSONEncoder().encode(NPCport) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(Port.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertEqual(NPCport, decode, "Decode result is different from original one")
    }

    func testCodableSelfPort() {
        guard let encode = try? JSONEncoder().encode(selfport) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(Port.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertEqual(selfport, decode, "Decode result is different from original one")
    }
}
