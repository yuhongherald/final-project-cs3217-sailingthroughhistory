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
    private var players = [GenericPlayer]()
    private var level: GameVariable<GenericLevel>?
    private var speedMultiplier = 1.0

    private var playerTurnOrder = [GenericPlayer]()

    required init(baseYear: Int) {
        gameTime = GameTime(baseYear: baseYear)
    }

    func subscribe(interface: Interface) {
        self.interface = interface
    }

    func loadLevel(level: GenericLevel) {
        players = level.getPlayers()
        for var player in players {
            player.interface = interface
        }
    }

    func getPlayers() -> [GenericPlayer] {
        return players
    }

    func getNextPlayer() -> GenericPlayer? {
        let nextPlayer = playerTurnOrder.removeFirst()
        nextPlayer.startTurn(speedMultiplier: speedMultiplier)
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
