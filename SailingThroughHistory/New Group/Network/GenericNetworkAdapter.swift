//
//  GenericNetworkAdapter.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericNetworkAdapter {
    func create() -> GenericNetworkSession
    func delete(session: GenericNetworkSession)
    func join(sessionID: String)
    func subscribe() // TODO: Write the protocol/class for arg
    func update()
}
