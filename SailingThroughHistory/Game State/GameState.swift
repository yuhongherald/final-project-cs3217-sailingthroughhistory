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

    private var interface: Interface?
    private var map: Map?
    private var players = [GenericPlayer]()
    private var speedMultiplier = 1.0

    private var playerTurnOrder = [GenericPlayer]()

    required init(baseYear: Int) {
        //TODO
        gameTime = GameTime()
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try gameTime = values.decode(GameTime.self, forKey: .gameTime)
        try map = values.decode(Map.self, forKey: .map)
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
        try container.encode(players, forKey: .players)
        try container.encode(speedMultiplier, forKey: .speedMultiplier)
    }

    private enum CodingKeys: String, CodingKey {
        case gameTime
        case map
        case players
        case speedMultiplier
    }

    func subscribe(interface: Interface) {
        self.interface = interface
    }

    func loadLevel(level: GenericLevel) {
        players = level.getPlayers()
        for var player in players {
            player.interface = interface
        }
        map = level.getMap()
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
}
