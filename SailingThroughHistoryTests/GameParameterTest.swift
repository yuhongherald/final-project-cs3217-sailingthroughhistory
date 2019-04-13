//
//  GameParameterTest.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/1/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class GameParameterTest: XCTestCase {
    func testUpdatePlayerParameter() {
        let originName = "name"
        let changedName = "changedName"

        // test update name and money
        let playerParameter = PlayerParameter(name: originName, teamName: "team", node: nil)
        playerParameter.set(name: changedName, money: 158)
        XCTAssertEqual(playerParameter.getName(), changedName, "Name is not successfully changed")
        XCTAssertEqual(playerParameter.getMoney(), 158, "Money is not successfully changed")
        XCTAssertTrue(playerParameter.getTeam() == Team(name: "team"), "Team is accidently changed")
        XCTAssertEqual(playerParameter.getStartingNode(), nil, "Node is accidently changed.")

        // test update starting node
        let port = Port(player: playerParameter.getPlayer(), name: "selfport", originX: 0, originY: 0)
        playerParameter.assign(port: port)
        XCTAssertEqual(playerParameter.getName(), changedName, "Name is accidently changed")
        XCTAssertEqual(playerParameter.getMoney(), 158, "Money is accidently changed")
        XCTAssertTrue(playerParameter.getTeam() == Team(name: "team"), "Team is accidently changed")
        XCTAssertTrue(isEqual(node: playerParameter.getStartingNode(), port), "Node is not successful changed.")
    }

    func testCodablePlayerParameter() {
        // test without node
        var playerParameter = PlayerParameter(name: "", teamName: "", node: nil)
        guard let encode1 = try? JSONEncoder().encode(playerParameter) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        var decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode1)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")

        // test with node
        playerParameter = PlayerParameter(name: "", teamName: "", node: Sea(name: "sea", originX: 1, originY: 100))
        guard let encode2 = try? JSONEncoder().encode(playerParameter) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode2)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")

        playerParameter = PlayerParameter(name: "", teamName: "",
                                          node: Port(player: nil, name: "NPCport", originX: 0, originY: 0))
        guard let encode3 = try? JSONEncoder().encode(playerParameter) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode3)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")

        playerParameter = PlayerParameter(name: "", teamName: "", node: nil)
        let port = Port(player: playerParameter.getPlayer(), name: "selfport", originX: 0, originY: 0)
        playerParameter.assign(port: port)
        guard let encode4 = try? JSONEncoder().encode(playerParameter) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode4)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")
    }

    func testUpdateItemParameter() {
        // test valid update
        var itemParameter = ItemParameter(itemType: .opium, displayName: "Opium", weight: 100, isConsumable: true)
        itemParameter.setBuyValue(value: 1234)
        itemParameter.setSellValue(value: 5678)
        itemParameter.setHalfLife(to: 20)
        XCTAssertEqual(itemParameter.getBuyValue(), 1234, "BuyValue is not successfully updated.")
        XCTAssertEqual(itemParameter.getSellValue(), 5678, "SellValue is not successfully updated.")
        XCTAssertEqual(itemParameter.getHalfLife(), 20, "HalfLife is not successfully updated.")

        // test invalid update
        itemParameter.setBuyValue(value: -1234)
        itemParameter.setSellValue(value: -5678)
        itemParameter.setHalfLife(to: -20)
        XCTAssertEqual(itemParameter.getBuyValue(), 1234, "BuyValue should not be updated to invalid value.")
        XCTAssertEqual(itemParameter.getSellValue(), 5678, "SellValue should not be updated to invalid value.")
        XCTAssertEqual(itemParameter.getHalfLife(), 20, "HalfLift should not be updated to invalid value.")
    }

    func testCodableItemParameter() {
        let itemParameter = ItemParameter(itemType: .opium, displayName: "Opium", weight: 100, isConsumable: true)
        guard let encode = try? JSONEncoder().encode(itemParameter) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(ItemParameter.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(itemParameter: decode, itemParameter), "Decode result is different from original one")
    }

    func testUpdateMap() {
        let map = Map(map: "worldmap1815", bounds: Rect(originX: 0, originY: 0, height: 100, width: 100))
        // test udpate map
        map.changeBackground("", with: Rect(originX: 100, originY: 100, height: 100, width: 100))
        XCTAssertEqual(map.map, "", "Map is not successfully updated")
        XCTAssertEqual(map.bounds, Rect(originX: 100, originY: 100, height: 100, width: 100), "Bounds is not successfully updated")

        // test add node
        let node1 = Sea(name: "sea1", originX: 0, originY: 0)
        map.addNode(node1)
        var nodes = Set<Node>()
        nodes.insert(node1)
        XCTAssertEqual(map.getNodes(), nodes, "Node is not successfully added")

        // test add path
        let node2 = Pirate(name: "sea2", originX: 10, originY: 10)
        map.addNode(node2)
        nodes.insert(node2)
        let path = Path(from: node1, to: node2)
        map.add(path: path)
        var paths = Set<Path>()
        paths.insert(path)
        XCTAssertEqual(map.getAllPaths(), paths, "Path is not successfully added")
        XCTAssertEqual(map.getPaths(of: node1), [path], "Path is not added to node1")
        XCTAssertEqual(map.getPaths(of: node2), [path], "Path is not added to node2")

        // test remove path
        map.removePath(path)
        paths.remove(path)
        XCTAssertEqual(map.getNodes(), nodes, "Node is not successfully removed")
        XCTAssertEqual(map.getAllPaths(), paths, "Path is not successfully removed")
        XCTAssertEqual(map.getPaths(of: node1), [], "Path is not successfully removed from node1")
        XCTAssertEqual(map.getPaths(of: node2), [], "Path is not successfully removed from node2")

        // test remove node
        map.add(path: path)
        paths.insert(path)
        map.removeNode(node1)
        nodes.remove(node1)
        paths.remove(path)
        XCTAssertEqual(map.getNodes(), nodes, "Node is not successfully removed")
        XCTAssertEqual(map.getAllPaths(), paths, "Path is not successfully removed")
        XCTAssertEqual(map.getPaths(of: node2), [], "Path is not successfully removed from node2")
    }

    func testCodableMap() {
        let map = Map(map: "", bounds: nil)
        let sea = Sea(name: "sea", originX: 0, originY: 0)
        let pirate = Pirate(name: "pirate", originX: 10, originY: 10)
        let NPCport = Port(player: nil, name: "port", originX: 20, originY: 20)
        let selfport = Port(player: Player(name: "player", team: Team(name: "testTeam"), node: NPCport), originX: 40, originY: 40)
        guard let encode1 = try? JSONEncoder().encode(map) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        var decode = try? JSONDecoder().decode(Map.self, from: encode1)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(map: decode, map), "Decode result is different from original one")

        // test map with sea and pirate added
        map.addNode(sea)
        map.addNode(pirate)
        guard let encode2 = try? JSONEncoder().encode(map) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        decode = try? JSONDecoder().decode(Map.self, from: encode2)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(map: decode, map), "Decode result is different from original one")

        // test map with NPCport added
        map.addNode(NPCport)
        guard let encode3 = try? JSONEncoder().encode(map) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        decode = try? JSONDecoder().decode(Map.self, from: encode3)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(map: decode, map), "Decode result is different from original one")

        // test map with player owned port added
        map.addNode(selfport)
        guard let encode4 = try? JSONEncoder().encode(map) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        decode = try? JSONDecoder().decode(Map.self, from: encode4)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(map: decode, map), "Decode result is different from original one")

        // test map with path added
        map.add(path: Path(from: sea, to: pirate))
        guard let encode5 = try? JSONEncoder().encode(map) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        decode = try? JSONDecoder().decode(Map.self, from: encode5)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(map: decode, map), "Decode result is different from original one")
    }

    private func isEqual(playerParameter: PlayerParameter?, _ rhs: PlayerParameter) -> Bool {
        guard let lhs = playerParameter else {
            return false
        }
        return lhs.getName() == rhs.getName() && lhs.getTeam() == rhs.getTeam()
            && lhs.getMoney() == rhs.getMoney() && isEqual(node: lhs.getStartingNode(), rhs.getStartingNode())
    }

    private func isEqual(node lhsNode: Node?, _ rhsNode: Node?) -> Bool {
        guard let lhs = lhsNode, let rhs = rhsNode else {
            return lhsNode == nil && rhsNode == nil
        }
        return lhs.frame == rhs.frame && lhs.image == rhs.image && lhs.name == rhs.image
    }

    private func isEqual(itemParameter: ItemParameter?, _ rhs: ItemParameter) -> Bool {
        guard let lhs = itemParameter else {
            return false
        }
        return lhs.getBuyValue() == rhs.getBuyValue() && lhs.getSellValue() == rhs.getSellValue()
            && lhs.getHalfLife() == rhs.getHalfLife() && lhs.displayName == rhs.displayName
            && lhs.isConsumable == rhs.isConsumable && lhs.unitWeight == rhs.unitWeight && lhs.itemType == rhs.itemType
    }

    private func isEqual(map: Map?, _ rhs: Map) -> Bool {
        guard let lhs = map else {
            return false
        }

        // check same nodes
        var lhsNodes = Set<Node>(lhs.getNodes())
        var rhsNodes = Set<Node>(rhs.getNodes())
        for node in lhsNodes {
            rhsNodes.remove(node)
        }
        if !rhsNodes.isEmpty {
            return false
        }

        // check same path
        var lhsPaths = Set<Path>(lhs.getAllPaths())
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
