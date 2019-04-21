//
//  NetworkInfo.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A class that stores information about the network connection information.
 */
class NetworkInfo {
    /// Player set tax actions, the player, and whether it succeeded.
    var setTaxActions = [Int: (PlayerAction, GenericPlayer, Bool)]()
    let deviceId: String
    let isMaster: Bool

    init(_ deviceId: String, _ isMaster: Bool) {
        self.deviceId = deviceId
        self.isMaster = isMaster
    }
}
