//
//  GameState.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GameState: GenericGameState {
    private var interface: Interface?

    private var players = [GenericPlayer]()
    private var level: GameVariable<GenericLevel>?
    private var speedMultiplier = 1.0

    private var playerTurnOrder = [GenericPlayer]()

    func subscribe(interface: Interface) {
        self.interface = interface
    }

    public func loadLevel(level: GenericLevel) {
        players = level.getPlayers()
        for var player in players {
            player.interface = interface
        }
    }

    public func getNextPlayer() -> GenericPlayer? {
        let nextPlayer = playerTurnOrder.removeFirst()
        nextPlayer.state.value = PlayerState.moving
        return nextPlayer
    }

    public func startNextTurn(speedMultiplier: Double) {
        self.speedMultiplier = speedMultiplier
        playerTurnOrder.removeAll()
        for player in players {
            playerTurnOrder.append(player)
        }
    }

    public func endGame() {
    }

}
