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

        // test update name and money
        let playerParameter = PlayerParameter(name: originName, teamName: "team", node: nil)
        playerParameter.set(money: 158)
        XCTAssertEqual(playerParameter.getMoney(), 158, "Money is not successfully changed")
        XCTAssertTrue(playerParameter.getTeam() == Team(name: "team"), "Team is accidently changed")
    }

    func testCodablePlayerParameter() {
        // test without node
        var playerParameter = PlayerParameter(name: "", teamName: "", node: nil)
        guard let encode1 = try? JSONEncoder().encode(playerParameter) else {
            XCTFail("Encode Failed")
            return
        }
        var decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode1)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")

        // test with node
        playerParameter = PlayerParameter(name: "", teamName: "", node: Sea(name: "sea", originX: 1, originY: 100))
        guard let encode2 = try? JSONEncoder().encode(playerParameter) else {
            XCTFail("Encode Failed")
            return
        }
        decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode2)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")

        // test with port
        playerParameter = PlayerParameter(name: "", teamName: "",
                                          node: Port(team: nil, name: "NPCport", originX: 0, originY: 0))
        guard let encode3 = try? JSONEncoder().encode(playerParameter) else {
            XCTFail("Encode Failed")
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
            XCTFail("Encode Failed")
            return
        }
        decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode4)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")
    }

    func testCodableItemParameter() {
        let itemParameter = ItemParameter.opium
        guard let encode = try? JSONEncoder().encode(itemParameter) else {
            XCTFail("Encode Failed")
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
            XCTFail("Encode Failed")
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
        // TODO
        /*
        return lhs.getBuyValue() == rhs.getBuyValue() && lhs.getSellValue() == rhs.getSellValue()
            && lhs.displayName == rhs.displayName
            && lhs.isConsumable == rhs.isConsumable && lhs.unitWeight == rhs.unitWeight && lhs.itemType == rhs.itemType
         */
        return true
    }

    private func isEqual(gameParameter: GameParameter?, _ rhs: GameParameter) -> Bool {
        guard let lhs = gameParameter else {
            return false
        }

        guard lhs.teamParameter.count == rhs.teamParameter.count, lhs.upgrades.count == rhs.upgrades.count else {
            return false
        }

        for parameter in lhs.teamParameter {
            guard let index = rhs.teamParameter.firstIndex(where: { isEqual(playerParameter: $0, parameter) }) else {
                return false
            }
            rhs.teamParameter.remove(at: index)
        }
        if !rhs.teamParameter.isEmpty {
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

        return lhs.itemParameters == rhs.itemParameters
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
