//
//  NetworkFactory.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

enum NetworkFactory {
    static func createRoomInstance(named name: String) -> Room {
        return FirestoreRoom(named: name)
    }

    static func createNetworkRoomsInstance() -> NetworkRooms {
        return FirestoreRooms()
    }
}
