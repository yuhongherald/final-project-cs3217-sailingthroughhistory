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
        }
        var decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode1)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")

        // test with node
        playerParameter = PlayerParameter(name: "", teamName: "", node: Sea(name: "sea", originX: 1, originY: 100))
        guard let encode2 = try? JSONEncoder().encode(playerParameter) else {
            XCTAssertThrowsError("Encode Failed")
        }
        decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode2)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")

        playerParameter = PlayerParameter(name: "", teamName: "",
                                          node: Port(player: nil, name: "NPCport", originX: 0, originY: 0))
        guard let encode3 = try? JSONEncoder().encode(playerParameter) else {
            XCTAssertThrowsError("Encode Failed")
        }
        decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode3)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")

        playerParameter = PlayerParameter(name: "", teamName: "", node: nil)
        let port = Port(player: playerParameter.getPlayer(), name: "selfport", originX: 0, originY: 0)
        playerParameter.assign(port: port)
        guard let encode4 = try? JSONEncoder().encode(playerParameter) else {
            XCTAssertThrowsError("Encode Failed")
        }
        decode = try? JSONDecoder().decode(PlayerParameter.self, from: encode4)
        XCTAssertNotNil(decode, "Decode Failed")
        XCTAssertTrue(isEqual(playerParameter: decode, playerParameter), "Decode result is different from original one")
    }

    func testUpdateItemParameter() {

    }

    func testCodableItemParameter() {

    }

    func testUpdateMap() {

    }

    func testCodableMap() {
        
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
}
