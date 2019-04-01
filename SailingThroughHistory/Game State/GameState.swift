//
//  GameState.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GameState: GenericGameState {
    var gameTime: GameTime
    var itemParameters = [ItemParameter]()

    private var interface: Interface?
    private(set) var map: Map?
    private var teams = [Team]()
    private var players = [GenericPlayer]()
    private var speedMultiplier = 1.0

    private var playerTurnOrder = [GenericPlayer]()

    required init(baseYear: Int) {
        gameTime = GameTime()
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try gameTime = values.decode(GameTime.self, forKey: .gameTime)
        try map = values.decode(Map.self, forKey: .map)
        try itemParameters = values.decode([ItemParameter].self, forKey: .itemParameters)
        try teams = values.decode([Team].self, forKey: .teams)
        try players = values.decode([Player].self, forKey: .players)
        try speedMultiplier = values.decode(Double.self, forKey: .speedMultiplier)
    }

    func encode(to encoder: Encoder) throws {
        guard let players = players as? [Player] else {
            return
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gameTime, forKey: .gameTime)
        try container.encode(map, forKey: .map)
        try container.encode(itemParameters, forKey: .itemParameters)
        try container.encode(teams, forKey: .teams)
        try container.encode(players, forKey: .players)
        try container.encode(speedMultiplier, forKey: .speedMultiplier)
    }

    private enum CodingKeys: String, CodingKey {
        case gameTime
        case map
        case itemParameters
        case teams
        case players
        case speedMultiplier
    }

    func subscribe(interface: Interface) {
        self.interface = interface
    }

    func loadLevel(level: GenericLevel) {
        teams = level.teams
        initializePlayersFromParameters(parameters: level.playerParameters)
        for var player in players {
            player.interface = interface
        }
        map = level.map
        itemParameters = level.itemParameters
    }

    func getPlayers() -> [GenericPlayer] {
        return players
    }

    func getNextPlayer() -> GenericPlayer? {
        let nextPlayer = playerTurnOrder.removeFirst()
        nextPlayer.startTurn(speedMultiplier: speedMultiplier, map: map)
        return nextPlayer
    }

    func startNextTurn(speedMultiplier: Double) {
        self.speedMultiplier = speedMultiplier
        playerTurnOrder.removeAll()
        for player in players {
            playerTurnOrder.append(player)
        }
    }

    func endGame() {
    }

    private func initializePlayersFromParameters(parameters: [PlayerParameter]) {
        players.removeAll()
        parameters.forEach {
            guard let node = $0.getStartingNode() else {
                NSLog("\($0.getName()) fails to be constructed because of loss of starting node.")
                return
            }
            let team = $0.getTeam()
            teams.append(team)
            players.append(Player(name: $0.getName(), team: team, node: node))
        }
    }
}
