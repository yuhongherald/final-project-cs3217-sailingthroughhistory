//
//  TestRoomConnection.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class TestRoomConnection: RoomConnection {
    var roomMasterId: String = "testRoom"
    var testCallback: () -> Void = {}
    private(set) var hasStarted: Bool = false
    private(set) var actions: [(String, [PlayerAction])] = []
    private(set) var turn: Int = 0
    private(set) var masterUpdated: Bool = false
    func addPlayer() {
        fatalError("Should not be called")
    }
    
    func startGame(initialState: GameState, background: Data, completion callback: @escaping (Error?) -> Void) throws {
        hasStarted = true
        callback(nil)
    }
    
    func push(currentState: GameState, forTurn turn: Int, completion callback: @escaping (Error?) -> Void) throws {
        masterUpdated = true
        callback(nil)
    }
    
    func subscribeToActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void) {
        // do nothing
    }
    
    func subscribeToMembers(with callback: @escaping ([RoomMember]) -> Void) {
        // do nothing
    }
    
    func push(actions: [PlayerAction], fromPlayer player: GenericPlayer, forTurnNumbered turn: Int, completion callback: @escaping (Error?) -> Void) throws {
        self.actions.append((player.deviceId, actions))
        testCallback()
        callback(nil)
    }
    
    func set(teams: [Team]) {
        fatalError("SHould not call")
    }
    
    func subscibeToTeamNames(with callback: @escaping ([String]) -> Void) {
        fatalError("SHould not call")
    }
    
    func subscribeToStart(with callback: @escaping (GameState, Data) -> Void) {
        fatalError("SHould not call")
    }
    
    func changeTeamName(for identifier: String, to teamName: String) throws {
        fatalError("SHould not call")
    }
    
    func changePlayerName(for identifier: String, to playerName: String) throws {
        fatalError("SHould not call")
    }
    
    func remove(player: String) {
        // do nothing
    }
    
    func getTurnActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void) {
        callback(actions, nil)
    }
    
    func changeRemovalCallback(to callback: @escaping () -> Void) {
        // do nothing
    }
    
    func subscribeToMasterState(for turn: Int, callback: @escaping (GameState) -> Void) {
        // do nothing
    }
    
    func verify(reference: String) throws {
        // do nothing
    }
    
    func disconnect() {
        // do nothing
    }
    
    
}
