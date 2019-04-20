//
//  PlayerInputController.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class PlayerInputController: GenericPlayerInputController {
    let network: GenericTurnSystemNetwork
    let data: GenericTurnSystemState

    init(network: GenericTurnSystemNetwork, data: GenericTurnSystemState) {
        self.network = network
        self.data = data
    }

    func checkInputAllowed(from player: GenericPlayer) throws {
        switch network.state {
        case .playerInput(let curPlayer, _):
            if player != curPlayer {
                throw PlayerActionError.wrongPhase(message: "Please wait for your turn")
            }
        default:
            throw PlayerActionError.wrongPhase(message: "Action called on wrong phase")
        }
    }

    func startPlayerInput(from player: GenericPlayer) {
        let endTime = Date().timeIntervalSince1970 + GameConstants.playerTurnDuration
        let turnNum = data.currentTurn
        DispatchQueue.global().asyncAfter(deadline: .now() + GameConstants.playerTurnDuration) { [weak self] in
            if player == self?.network.currentPlayer && self?.data.currentTurn == turnNum {
                self?.network.endTurn()
            }
        }

        network.state = .playerInput(from: player, endTime: endTime)
    }
}
