//
//  LocalRoomConnectionTest.swift
//  SailingThroughHistoryTests
//
//  Created by Jason Chong on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class LocalRoomConnectionTest: XCTestCase {
    private let deviceId = "aa"
    func testInit() {
        let connection = LocalRoomConnection(deviceId: deviceId)
        XCTAssertEqual(connection.roomMasterId, deviceId, "Room master id is incorrect.")
    }

    func testAddPlayerAndMemberSubsciption() throws {
        let connection = LocalRoomConnection(deviceId: deviceId)
        var members = [RoomMember]()
        members.append(RoomMember(identifier: "aaaa", playerName: "aaa", teamName: nil, deviceId: deviceId))
        connection.subscribeToMembers {
            members = $0
        }
        XCTAssertTrue(members.isEmpty, "callback not called on subsciption")
        connection.addPlayer()
        XCTAssertEqual(members.count, 1, "Player not added properly")
        XCTAssertEqual(members[0].deviceId, deviceId)
        connection.addPlayer()
        XCTAssertEqual(members.count, 2, "Player not added properly")
        XCTAssertNotEqual(members[0].identifier, members[1].identifier)
        XCTAssertEqual(members[1].deviceId, deviceId)
        try connection.changeTeamName(for: members[0].identifier, to: "team1")
        XCTAssertEqual(members[0].teamName, "team1", "Team name not changed properly")
        XCTAssertNil(members[1].teamName, "Team name not changed properly")
        try connection.changePlayerName(for: members[1].identifier, to: "aaaa")
        XCTAssertEqual(members[1].playerName, "aaaa", "Player name not changed properly")
        XCTAssertNotEqual(members[0].playerName, "aaaa", "Player name not changed properly")
        connection.remove(player: members[1].identifier)
        XCTAssertEqual(members.count, 1, "Player not removed properly")
        XCTAssertNotEqual(members[0].playerName, "aaaa", "Player name not changed properly")
    }

    func testActionsAndSubscription() throws {
        let connection = LocalRoomConnection(deviceId: deviceId)
        let player1 = GameMaster(name: "a", deviceId: deviceId)
        let player2 = GameMaster(name: "x", deviceId: deviceId)
        var actions1 = [(String, [PlayerAction])]()
        actions1.append(("x", [.pirate]))
        var actions2 = [(String, [PlayerAction])]()
        actions2.append(("a", [.pirate]))
        connection.subscribeToActions(for: 1) {
            actions1 = $0
            XCTAssertNil($1, "Error is not nil")
        }
        connection.subscribeToActions(for: 2) {
            actions2 = $0
            XCTAssertNil($1, "Error is not nil")
        }
        XCTAssertTrue(actions1.isEmpty, "callback not called on subsciption")
        XCTAssertTrue(actions2.isEmpty, "callback not called on subsciption")
        try connection.push(actions: [.pirate], fromPlayer: player1, forTurnNumbered: 1) { _ in }
        try connection.push(actions: [.pirate], fromPlayer: player2, forTurnNumbered: 2) { _ in }
        XCTAssertEqual(actions1.count, 1, "Action not added properly")
        XCTAssertEqual(actions2.count, 1, "Action not added properly")
        XCTAssertEqual(actions1[0].0, player1.name, "Action not added properly")
        if case PlayerAction.pirate = actions1[0].1[0] {
        } else {
            XCTFail("Action not added properly")
        }

        if case PlayerAction.pirate = actions2[0].1[0] {
        } else {
            XCTFail("Action not added properly")
        }
        XCTAssertEqual(actions2[0].0, player2.name, "Action not added properly")
    }

    func testSetTeamNameAndSubscribe() {
        let connection = LocalRoomConnection(deviceId: deviceId)
        var teams = [String]()
        teams.append("aaa")
        connection.subscibeToTeamNames {
            teams = $0
        }
        XCTAssertTrue(teams.isEmpty, "Callback not called on subscription")
        connection.set(teams: [Team(name: "team1"), Team(name: "team2")])
        XCTAssertEqual(teams, ["team1", "team2"])
    }
}
