//
//  WaitingRoom.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 1/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class GameRoom {
    private var observers = [(callback: ([RoomMember]) -> Void, observer: AnyObject?)]()
    private(set) var players: [RoomMember] {
        didSet {
            observers = observers.filter { $0.observer != nil }
            observers.forEach {
                $0.callback(players)
            }
        }
    }
    private var roomMaster: String?
    var parameters: GameParameter? {
        didSet {
            updateTeamList()
        }
    }
    private var connection: RoomConnection
    private var teamNames = [String]()
    let identifier: String
    var gameMaster: String?

    init(fromConnection connection: RoomConnection) {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            fatalError("Device has no uuid")
        }
        self.identifier = deviceId
        self.players = []
        self.connection = connection
        connection.subscribeToMembers { [weak self] in
            var players = $0
            for (index, player) in players.enumerated() where player.playerName == self?.gameMaster {
                players[index].isGameMaster = true
            }
            self?.players = players
        }

        connection.subscibeToTeamNames { [weak self] in
            self?.teamNames = $0
        }
    }

    func subscribeToMembers(with callback: @escaping ([RoomMember]) -> Void, observer: AnyObject?) {
        observers.append((callback: callback, observer: observer))
        callback(players)
    }

    func isRoomMaster() -> Bool {
        return identifier == connection.roomMasterId
    }

    func disconnect() {
        connection.disconnect()
    }

    func changeTeam(of identifier: String) {
        guard teamNames.count > 0,
            let playerIndex = players.firstIndex(where: { $0.playerName == identifier }) else {
            return
        }

        let player = players[playerIndex]
        let newTeamIndex = ((teamNames.index(of: player.teamName ?? "") ?? 0) + 1) % teamNames.count
        let newTeamName = teamNames[newTeamIndex]
        connection.changeTeamName(for: player.playerName, to: newTeamName)
    }

    func remove(player playerName: String) {
        connection.remove(player: playerName)
    }

    func makeGameMaster(_ identifier: String) {
        guard isRoomMaster(),
            let playerIndex = players.firstIndex(where: { $0.playerName == identifier }) else {
            return
        }
        for index in players.indices {
            players[index].isGameMaster = false
        }
        gameMaster = identifier
        players[playerIndex].isGameMaster = true
    }

    private func updateTeamList() {
        guard isRoomMaster(),
            let parameters = parameters else {
            return
        }

        connection.set(teams: parameters.teams)
    }
}
