//
//  PlayerActionBatch.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 4/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A struct used to store the actions a player has made in an encodable format.
 */
struct PlayerActionBatch: Codable {
    let playerName: String
    let actions: [PlayerAction]
}
