//
//  LocalRoom.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class LocalRoom: Room {
    let name = "Local"

    func getConnection(completion callback: @escaping (RoomConnection?, Error?) -> Void) {
        return
    }
}
