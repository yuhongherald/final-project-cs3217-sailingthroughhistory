//
//  WaitingRoomPlayer.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 1/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct RoomMember {
    let playerName: String
    let teamName: String?
    let deviceId: String
    var isGameMaster = false
    var hasTeam: Bool {
        return teamName != nil
    }

    init(playerName: String, teamName: String?, deviceId: String) {
        self.playerName = playerName
        self.teamName = teamName
        self.deviceId = deviceId
    }
}
