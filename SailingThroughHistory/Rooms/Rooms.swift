//
//  Rooms.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class Rooms {
    private(set) var rooms = [Room]() {
        didSet {
            self.subscriptions.forEach { $0(rooms) }
        }
    }
    var subscriptions = [([Room]) -> Void]()
    var networkRooms: NetworkRooms = NetworkFactory.createNetworkRoomsInstance()

    init() {
        self.networkRooms.subscribe { [weak self] roomNames in
            let rooms = roomNames.map { NetworkFactory.createRoomInstance(named: $0) }
            self?.rooms = rooms
        }
    }

    func subscribe(with callback: @escaping ([Room]) -> Void) {
        callback(rooms)
        subscriptions.append(callback)
    }
}
