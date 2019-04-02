//
//  Network.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 26/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol RoomConnection {
    var roomMasterId: String { get }

    static func getConnection(for room: FirestoreRoom,
                              removed removedCallback: @escaping () -> Void,
                              completion callback: @escaping (RoomConnection?, Error?) -> ())

    func startGame(initialState: GameState, completion callback: @escaping (Error?) -> Void) throws

    func push(currentState: GameState, completion callback: @escaping (Error?) -> Void) throws

    /// TODO: CHANGE TYPE
    func subscribeToActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void)

    func subscribeToPlayerTeams(with callback: @escaping ([WaitingRoomPlayer]) -> Void)

    func push(actions: [PlayerAction], fromPlayer player: Player,
              forTurnNumbered turn: Int,
              completion callback: @escaping (Error?) -> ()) throws

    func checkTurnEnd(actions: [Map], forTurnNumbered turn: Int) throws

    func set(teams: [Team])

    func subscibeToTeamNames(with callback: @escaping ([String]) -> Void)

    func subscribeToStart(with callback: @escaping (GameState) -> Void)

    func changeTeamName(for identifier: String, to teamName: String)
}
