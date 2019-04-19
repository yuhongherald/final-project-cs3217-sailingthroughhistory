//
//  NetworkRooms.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Protocol for a collection of rooms in the network.
protocol NetworkRooms {
    /// Subscribe to name of rooms on the network.
    ///
    /// - Parameter callback: called with an array of all names of rooms on the network on subsciption and whenever
    ///                       the collection changes.
    func subscribe(with callback: @escaping ([String]) -> Void)
}
