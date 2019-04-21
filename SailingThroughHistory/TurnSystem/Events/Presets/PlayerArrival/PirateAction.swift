//
//  PirateAction.swift
//  SailingThroughHistory
//
//  Created by Herald on 11/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * An action that is intended to invoke a pirate's response on chasing a player.
 */
class PirateAction: Modify {
    private let player: GenericPlayer
    init(player: GenericPlayer, turnSystem: GenericTurnSystem) {
        self.player = player
    }
    func modify() {
    }
}
