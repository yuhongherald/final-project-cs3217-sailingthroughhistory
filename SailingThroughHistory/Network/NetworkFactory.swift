//
//  NetworkFactory.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Factory for creating objects in the Network module.
enum NetworkFactory {
    static func createRoomInstance(named name: String) throws -> Room {
        try verify(name)
        return FirestoreRoom(named: name)
    }

    static func createNetworkRoomsInstance() -> NetworkRooms {
        return FirestoreRooms()
    }

    static func verify(_ name: String) throws {
        guard !name.isEmpty else {
            throw StorageError.invalidName(message: "Empty name.")
        }

        guard name.count < 255 else {
            throw StorageError.invalidName(message: "Name is too long.")
        }

        guard name.range(of: "[^a-zA-Z0-9-]", options: .regularExpression) == nil else {
            throw StorageError.invalidName(message: "Name contains invalid symbol. Only alphanumeric and - is allowed.")
        }
    }
}
