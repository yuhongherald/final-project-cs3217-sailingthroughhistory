//
//  LocalRoomConnection.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class LocalRoomConnection: RoomConnection {
    var roomMasterId: String
    var roomMemberCallbacks = [([RoomMember]) -> Void]()
    var roomMembers = [RoomMember]() {
        didSet {
            roomMemberCallbacks.forEach { $0(roomMembers) }
        }
    }
    var gameStartCallbacks = [(GameState, Data) -> Void]()
    var initialState: (state: GameState, background: Data)? {
        didSet {
            guard let initialState = initialState else {
                return
            }
            gameStartCallbacks.forEach { $0(initialState.state, initialState.background) }
        }
    }
    var currentState = [Int: GameState]()
    var currentStateCallbacks = [Int: [(GameState) -> Void]]()
    var actionCallbacks = [Int: [([(String, [PlayerAction])], Error?) -> Void]]()
    var actions = [Int: [(String, [PlayerAction])]]()
    var teams = [String]() {
        didSet {
            teamCallbacks.forEach { $0(teams) }
        }
    }
    var teamCallbacks = [([String]) -> Void]()

    init(deviceId: String) {
        self.roomMasterId = deviceId
    }

    func addPlayer() {
        let member = RoomMember(identifier: "\(roomMembers.count)-Play", playerName: nil, teamName: nil, deviceId: roomMasterId)
        roomMembers.append(member)
    }

    func startGame(initialState: GameState, background: Data, completion callback: @escaping (Error?) -> Void) throws {
        self.initialState = (state: initialState, background: background)
        callback(nil)
    }

    func push(currentState: GameState, forTurn turn: Int, completion callback: @escaping (Error?) -> Void) throws {
        self.currentState[turn] = currentState
        self.currentStateCallbacks[turn, default: []].forEach { $0(currentState) }
        callback(nil)
    }

    func subscribeToMasterState(for turn: Int, callback: @escaping (GameState) -> Void) {
        currentStateCallbacks[turn, default: []].append(callback)

        guard let state = currentState[turn] else {
            return
        }

        callback(state)
    }

    func subscribeToActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void) {
        actionCallbacks[turn, default: []].append(callback)

        guard let actions = actions[turn] else {
            return
        }

        callback(actions, nil)
    }

    func subscribeToMembers(with callback: @escaping ([RoomMember]) -> Void) {
        roomMemberCallbacks.append(callback)
        callback(roomMembers)
    }

    func push(actions: [PlayerAction], fromPlayer player: GenericPlayer, forTurnNumbered turn: Int,
              completion callback: @escaping (Error?) -> Void) throws {
        self.actions[turn, default: []].append((player.name, actions))
        self.actionCallbacks[turn, default: []].forEach { $0(self.actions[turn, default: []], nil) }
        callback(nil)
    }

    func set(teams: [Team]) {
        self.teams = teams.map { $0.name }
    }

    func subscibeToTeamNames(with callback: @escaping ([String]) -> Void) {
        teamCallbacks.append(callback)
        callback(teams)
    }

    func subscribeToStart(with callback: @escaping (GameState, Data) -> Void) {
        gameStartCallbacks.append(callback)
        guard let initialState = self.initialState else {
            return
        }

        callback(initialState.state, initialState.background)
    }

    func changeTeamName(for identifier: String, to teamName: String) throws {
        for (index, member) in roomMembers.enumerated() where member.identifier == identifier {
            roomMembers[index] = RoomMember(identifier: member.identifier,
                                            playerName: member.playerName,
                                            teamName: teamName,
                                            deviceId: member.deviceId)
        }
    }

    func changePlayerName(for identifier: String, to playerName: String) throws {
        for (index, member) in roomMembers.enumerated() where member.identifier == identifier {
            roomMembers[index] = RoomMember(identifier: member.identifier,
                                            playerName: playerName,
                                            teamName: member.teamName,
                                            deviceId: member.deviceId)
        }
    }

    func remove(player: String) {
        roomMembers = roomMembers.filter { $0.identifier != player }
    }

    func changeRemovalCallback(to callback: @escaping () -> Void) {
        // Removal callback should never be triggered in a local game.
        return
    }

    func getTurnActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void) {
        callback(actions[turn] ?? [], nil)
    }

    func verify(reference: String) throws {
    }

    func disconnect() {
    }
}
