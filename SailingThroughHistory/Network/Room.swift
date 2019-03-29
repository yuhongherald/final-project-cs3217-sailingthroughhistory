//
//  Room.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol Room {
    var name: String { get }

    static func getAllRooms(completion: @escaping ([Room]) -> Void)
    func getConnection(removalCallback: @escaping () -> Void,
                       completion callback: @escaping (RoomConnection?, Error?) -> Void)
}
