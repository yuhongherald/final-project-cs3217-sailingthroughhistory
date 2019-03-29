//
//  GenericNetworkSession.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericNetworkSession {
    var ownerIdentifier: String { get }
    var selfIdentifier: String { get }
    var data: Int { get } // TODO: Write proper data class/protocol
}
