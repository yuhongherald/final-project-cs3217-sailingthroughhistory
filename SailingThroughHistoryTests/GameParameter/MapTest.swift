//
//  MapTest.swift
//  SailingThroughHistoryTests
//
//  Created by ysq on 4/13/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class MapTest: XCTestCase {
    var map: Map = Map(map: "", bounds: Rect(originX: 0, originY: 0, height: 1000, width: 1024))
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
        map = Map(map: "", bounds: Rect(originX: 0, originY: 0, height: 1000, width: 1024))
        sea = Sea(name: "sea", originX: 0, originY: 0)
        pirateSea = Sea(name: "pirateSea", originX: 100, originY: 100)
        let pirate = PirateIsland(in: pirateSea)
        pirateSea.add(object: pirate)
        NPCport = Port(team: nil, name: "port", originX: 20, originY: 20)
        selfport = Port(team: Team(name: "testTeam"), originX: 40, originY: 40)
    }

    func testUpdateMap() {
        let map = Map(map: "worldmap1815", bounds: Rect(originX: 0, originY: 0, height: 100, width: 100))
        // test udpate map
        map.changeBackground("", with: Rect(originX: 100, originY: 100, height: 100, width: 100))
        XCTAssertEqual(map.map, "", "Map is not successfully updated")
        XCTAssertEqual(map.bounds, Rect(originX: 100, originY: 100,
                                        height: 100, width: 100), "Bounds is not successfully updated")
    }

    func testUpdateNodePath() {
        // test add node
        let node1 = Sea(name: "sea1", originX: 0, originY: 0)
        map.addNode(node1)
        var nodes = Set<Node>()
        nodes.insert(node1)
        XCTAssertEqual(map.getNodes(), nodes, "Node is not successfully added")

        // test add path
        let node2 = Sea(name: "sea2", originX: 10, originY: 10)
        let pirate = PirateIsland(in: node2)
        node2.add(object: pirate)
        map.addNode(node2)
        nodes.insert(node2)
        let path = Path(from: node1, to: node2)
        map.add(path: path)
        var paths = Set<Path>()
        paths.insert(path)
        XCTAssertEqual(map.getAllPaths(), paths, "Path is not successfully added")
        XCTAssertEqual(map.getPaths(of: node1), [path], "Path is not added to node1")
        XCTAssertEqual(map.getPaths(of: node2), [path], "Path is not added to node2")

        // test remove node
        map.add(path: path)
        paths.insert(path)
        map.removeNode(node1)
        nodes.remove(node1)
        paths.remove(path)
        XCTAssertEqual(map.getNodes(), nodes, "Node is not successfully removed")
        XCTAssertEqual(map.getAllPaths(), paths, "Path is not successfully removed")
        XCTAssertEqual(map.getPaths(of: node2), [], "Path is not successfully removed from node2")

        // test remove path
        map.removePath(path)
        paths.remove(path)
        XCTAssertEqual(map.getNodes(), nodes, "Node is not successfully removed")
        XCTAssertEqual(map.getAllPaths(), paths, "Path is not successfully removed")
        XCTAssertEqual(map.getPaths(of: node1), [], "Path is not successfully removed from node1")
        XCTAssertEqual(map.getPaths(of: node2), [], "Path is not successfully removed from node2")
    }

    func testUpdateObject() {
        // test add object
        var objects = [GameObject]()
        let ship = ShipUI(ship: Ship(node: sea, itemsConsumed: []))
        map.addGameObject(gameObject: ship)
        objects.append(ship)
        XCTAssertEqual(map.gameObjects.value, objects, "Objects are not successfully added")
    }

    func testCodableMap() {
        guard let encode = try? JSONEncoder().encode(map) else {
            XCTFail("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(Map.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(map: decode, map), "Decode result is different from original one")
    }

    func testCodableMapFull() {
        map.addNode(sea)
        map.addNode(pirateSea)
        map.addNode(selfport)
        map.addNode(NPCport)
        map.add(path: Path(from: sea, to: pirateSea))
        map.add(path: Path(from: pirateSea, to: NPCport))
        map.add(path: Path(from: NPCport, to: sea))
        map.addGameObject(gameObject: PirateIsland(in: pirateSea))
        map.addGameObject(gameObject: ShipUI(ship: Ship(node: selfport, itemsConsumed: [])))

        guard let encode = try? JSONEncoder().encode(map) else {
            XCTFail("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(Map.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(map: decode, map), "Decode result is different from original one")
    }

    func testCodableMapWithSea() {
        // test map with sea
        map.addNode(sea)
        guard let encode = try? JSONEncoder().encode(map) else {
            XCTFail("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(Map.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(map: decode, map), "Decode result is different from original one")
        print(String(data: encode, encoding: String.Encoding.utf8) ?? "Data could not be printed")
    }

    func testCodableMapWithPirate() {
        map.addNode(pirateSea)
        guard let encode = try? JSONEncoder().encode(map) else {
            XCTFail("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(Map.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(map: decode, map), "Decode result is different from original one")
        print(String(data: encode, encoding: String.Encoding.utf8) ?? "Data could not be printed")
    }

    func testCodableMapWithNPCPort() {
        map.addNode(NPCport)
        guard let encode = try? JSONEncoder().encode(map) else {
            XCTFail("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(Map.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(map: decode, map), "Decode result is different from original one")
        print(String(data: encode, encoding: String.Encoding.utf8) ?? "Data could not be printed")
    }

    func testCodableMapWithPlayerPort() {
        // test map with player owned port added
        map.addNode(selfport)
        guard let encode = try? JSONEncoder().encode(map) else {
            XCTFail("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(Map.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(map: decode, map), "Decode result is different from original one")
    }

    func testCodableMapWithPath() {
        // test map with path added
        map.addNode(sea)
        map.addNode(pirateSea)
        let path = Path(from: sea, to: pirateSea)
        path.modifiers.append(Weather())
        map.add(path: path)
        guard let encode = try? JSONEncoder().encode(map) else {
            XCTFail("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(Map.self, from: encode)
        print(String(data: encode, encoding: String.Encoding.utf8) ?? "Data could not be printed")
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(map: decode, map), "Decode result is different from original one")
    }

    private func isEqual(map: Map?, _ rhs: Map) -> Bool {
        guard let lhs = map else {
            return false
        }

        // check same nodes
        let lhsNodes = Set<Node>(lhs.getNodes())
        var rhsNodes = Set<Node>(rhs.getNodes())
        for node in lhsNodes {
            rhsNodes.remove(node)
        }
        if !rhsNodes.isEmpty {
            return false
        }

        // check same path
        let lhsPaths = Set<Path>(lhs.getAllPaths())
        var rhsPaths = Set<Path>(rhs.getAllPaths())
        for path in lhsPaths {
            rhsPaths.remove(path)
        }
        if !rhsPaths.isEmpty {
            return false
        }
        return lhs.map == rhs.map && lhs.bounds == rhs.bounds
    }
}
