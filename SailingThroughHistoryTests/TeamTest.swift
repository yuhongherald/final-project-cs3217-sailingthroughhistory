//
//  TeamTest.swift
//  SailingThroughHistoryTests
//
//  Created by ysq on 4/13/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class TeamTest: XCTestCase {
    var team = Team(name: "testTeam")
    var sea = Sea(name: "sea", originX: 0, originY: 100)
    var npcPort = SailingThroughHistory.Port(team: nil, name: "NPCport", originX: 0, originY: 100)
    var selfPort = SailingThroughHistory.Port(team: Team(name: "testTeam"), originX: 100, originY: 100)

    override func setUp() {
        Node.nextID = 0
        Node.reuseID = []
        team = Team(name: "testTeam")
        sea = Sea(name: "sea", originX: 0, originY: 100)
    }

    func testUpdateTeam() {
        let team = Team(name: "testTeam")
        let originMoney = team.money.value
        team.updateMoney(by: 100)
        XCTAssertEqual(team.money.value, originMoney + 100, "Money is not successfully updated.")
        team.updateMoney(by: -100)
        XCTAssertEqual(team.money.value, originMoney, "Money is not successfully updated.")

        let sea = Sea(name: "sea", originX: 0, originY: 100)
        team.start(from: sea)
        XCTAssertEqual(team.startingNode, sea, "StartingNode is not successfully updated.")
        let port = SailingThroughHistory.Port(team: nil, name: "port", originX: 100, originY: 10)
        team.start(from: port)
        XCTAssertEqual(team.startingNode, port, "StartingNode is not successfully updated.")
    }

    func testCodableTeamWithoutNode() {
        team.updateMoney(by: 100)
        check(team)
    }

    func testCodableTeamWithSea() {
        setUp()

        // test sea without objects
        team.start(from: sea)
        check(team)

        // test sea with objects
        sea.add(object: Pirate(in: sea))
        check(team)
    }

    func testCodableTeamWithPort() {
        team.start(from: npcPort)
        check(team)

        team.start(from: selfPort)
        check(team)
    }

    private func check(_ team: Team) {
        guard let encode = try? JSONEncoder().encode(team) else {
        XCTAssertThrowsError("Encode Failed")
        return
        }
        let decode = try? JSONDecoder().decode(Team.self, from: encode)
        XCTAssertNotNil(decode, "Decode Failed")
        print(String(data: encode, encoding: String.Encoding.utf8) ?? "Data could not be printed")
        XCTAssertTrue(isEqual(team: decode, team), "Decode result is different from original one")
    }

    private func isEqual(team: Team?, _ rhs: Team) -> Bool {
        guard let lhs = team else {
            return false
        }
        return lhs.name == rhs.name
            && lhs.startId == rhs.startId && lhs.money.value == rhs.money.value
    }
}
