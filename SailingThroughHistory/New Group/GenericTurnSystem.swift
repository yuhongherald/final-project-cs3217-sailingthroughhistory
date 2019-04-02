//
//  GenericTurnSystem.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericTurnSystem {
    var gameState: GenericGameState { get }
    func makeAction(for player: GenericPlayer, action: PlayerAction) -> Bool
    func watchMasterUpdate(gameState: GenericGameState)
    func watchTurnFinished(playerActions: [(GenericPlayer, [PlayerAction])])
}
