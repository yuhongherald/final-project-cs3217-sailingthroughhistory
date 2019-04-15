//
//  PlayerActionBatch.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 4/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct PlayerActionBatch: Codable {
    let playerName: String
    let actions: [PlayerAction]
}
