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

    init(deviceId: String) {
        self.roomMasterId = deviceId
    }

    func addPlayer() {
        return
    }

    func startGame(initialState: GameState, background: Data, completion callback: @escaping (Error?) -> Void) throws {
        return
    }

    func push(currentState: GameState, completion callback: @escaping (Error?) -> Void) throws {
        return
    }

    func subscribeToActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void) {
        return
    }

    func subscribeToMembers(with callback: @escaping ([RoomMember]) -> Void) {
        return
    }

    func push(actions: [PlayerAction], fromPlayer player: GenericPlayer, forTurnNumbered turn: Int, completion callback: @escaping (Error?) -> ()) throws {
        return
    }

    func checkTurnEnd(actions: [Map], forTurnNumbered turn: Int) throws {
        return
    }

    func set(teams: [Team]) {
        return
    }

    func subscibeToTeamNames(with callback: @escaping ([String]) -> Void) {
        return
    }

    func subscribeToStart(with callback: @escaping (GameState, Data) -> Void) {
        return
    }

    func changeTeamName(for identifier: String, to teamName: String) {
        return
    }

    func remove(player: String) {
        return
    }

    func changeRemovalCallback(to callback: @escaping () -> Void) {
        return
    }


}
