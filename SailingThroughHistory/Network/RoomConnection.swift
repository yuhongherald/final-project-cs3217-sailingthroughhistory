//
//  Network.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 26/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol RoomConnection {
    var roomMasterId: String { get }

    func addPlayer()

    func startGame(initialState: GameState, background: Data, completion callback: @escaping (Error?) -> Void) throws

    func push(currentState: GameState, forTurn turn: Int, completion callback: @escaping (Error?) -> Void) throws

    func subscribeToActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void)

    func subscribeToMembers(with callback: @escaping ([RoomMember]) -> Void)

    func push(actions: [PlayerAction], fromPlayer player: GenericPlayer,
              forTurnNumbered turn: Int,
              completion callback: @escaping (Error?) -> Void) throws

    func set(teams: [Team])

    func subscibeToTeamNames(with callback: @escaping ([String]) -> Void)

    func subscribeToStart(with callback: @escaping (GameState, Data) -> Void)

    func changeTeamName(for identifier: String, to teamName: String)

    func changePlayerName(for identifier: String, to playerName: String)

    func remove(player: String)

    func getTurnActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void)

    func changeRemovalCallback(to callback: @escaping () -> Void)

    func subscribeToMasterState(for turn: Int, callback: @escaping (GameState) -> Void)

    func disconnect()
}
