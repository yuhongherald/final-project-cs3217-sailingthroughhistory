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

        // test with port
        playerParameter = PlayerParameter(name: "", teamName: "",
                                          node: Port(team: nil, name: "NPCport", originX: 0, originY: 0))
        guard let encode3 = try? JSONEncoder().encode(playerParameter) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode3)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")

        playerParameter = PlayerParameter(name: "", teamName: "", node: nil)
        let team = Team(name: "team")
        let port = Port(team: team, name: "selfport", originX: 0, originY: 0)
        port.assignOwner(team)
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
        itemParameter.setHalfLife(to: 20)
        XCTAssertEqual(itemParameter.getHalfLife(), 20, "HalfLife is not successfully updated.")

        // test invalid update
        itemParameter.setHalfLife(to: -20)
        XCTAssertEqual(itemParameter.getHalfLife(), 20, "HalfLife should not be updated to invalid value.")
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

    func testCodableGameParameter() {
        let gameParameter = GameParameter(map: Map(
            map: "map", bounds: Rect(originX: 0, originY: 0, height: 100, width: 100)), teams: ["team1", "team2"])
        guard let encode = try? JSONEncoder().encode(gameParameter) else {
            XCTAssertThrowsError("Encode Failed")
            return
        }
        let decode = try? JSONDecoder().decode(GameParameter.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(gameParameter: decode, gameParameter), "Decode result is different from original one")
    }

    private func isEqual(playerParameter: PlayerParameter?, _ rhs: PlayerParameter) -> Bool {
        guard let lhs = playerParameter else {
            return false
        }
        return lhs.getName() == rhs.getName() && lhs.getTeam() == rhs.getTeam()
            && lhs.getMoney() == rhs.getMoney()
    }

    private func isEqual(node lhsNode: Node?, _ rhsNode: Node?) -> Bool {
        guard let lhs = lhsNode, let rhs = rhsNode else {
            return lhsNode == nil && rhsNode == nil
        }
        return lhs.frame == rhs.frame && lhs.name == rhs.name
    }

    private func isEqual(itemParameter: ItemParameter?, _ rhs: ItemParameter) -> Bool {
        guard let lhs = itemParameter else {
            return false
        }
        return lhs.getBuyValue(ports: []) == rhs.getBuyValue(ports: []) && lhs.getSellValue(ports: []) == rhs.getSellValue(ports: [])
            && lhs.getHalfLife() == rhs.getHalfLife() && lhs.displayName == rhs.displayName
            && lhs.isConsumable == rhs.isConsumable && lhs.unitWeight == rhs.unitWeight && lhs.itemType == rhs.itemType
    }

    private func isEqual(gameParameter: GameParameter?, _ rhs: GameParameter) -> Bool {
        guard let lhs = gameParameter else {
            return false
        }

        guard lhs.playerParameters.count == rhs.playerParameters.count, lhs.upgrades.count == rhs.upgrades.count else {
            return false
        }

        for parameter in lhs.playerParameters {
            guard let index = rhs.playerParameters.firstIndex(where: { isEqual(playerParameter: $0, parameter) }) else {
                return false
            }
            rhs.playerParameters.remove(at: index)
        }
        if !rhs.playerParameters.isEmpty {
            return false
        }

        for upgrade in lhs.upgrades {
            guard let index = rhs.upgrades.firstIndex(where: { isEqual(upgrade: $0, upgrade) }) else {
                return false
            }
            rhs.upgrades.remove(at: index)
        }
        if !rhs.upgrades.isEmpty {
            return false
        }

        return lhs.eventParameters == rhs.eventParameters && lhs.itemParameters == rhs.itemParameters
             && lhs.numOfTurn == rhs.numOfTurn && lhs.timeLimit == rhs.timeLimit
            && lhs.teams == rhs.teams && isEqual(map: lhs.map, rhs.map)
    }

    private func isEqual(upgrade: Upgrade?, _ rhs: Upgrade) -> Bool {
        guard let lhs = upgrade else {
            return false
        }
        return lhs.name == rhs.name && lhs.cost == rhs.cost && lhs.type == rhs.type
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
