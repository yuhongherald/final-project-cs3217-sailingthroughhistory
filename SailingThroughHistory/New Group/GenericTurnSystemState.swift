//
//  GenericTurnSystemState.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericTurnSystemState {
    var gameState: GameState { get }
    var currentPlayerIndex: Int { get set }
}
