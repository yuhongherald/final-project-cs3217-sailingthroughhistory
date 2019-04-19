//
//  Room.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// A wrapper for information of a room on the network. To be used for getting available rooms in the network.
protocol Room {
    var name: String { get }

    func getConnection(completion callback: @escaping (RoomConnection?, Error?) -> Void)
}
