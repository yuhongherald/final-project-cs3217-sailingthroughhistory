//
//  WaitingRoomPlayer.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 1/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct RoomMember {
    let identifier: String
    let playerName: String
    let teamName: String?
    let deviceId: String
    var isGameMaster = false
    var hasTeam: Bool {
        return teamName != nil
    }

    init(identifier: String, playerName: String?, teamName: String?, deviceId: String) {
        self.identifier = identifier
        self.playerName = playerName ?? String(identifier.prefix(8))
        self.teamName = teamName
        self.deviceId = deviceId
    }
}
