//
//  WaitingRoomPlayer.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 1/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct WaitingRoomPlayer {
    let playerName: String
    let teamName: String?
    var hasTeam: Bool {
        return teamName != nil
    }
}
