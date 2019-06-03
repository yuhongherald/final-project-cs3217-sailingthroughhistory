//
//  PlayerInputControllerFactory.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class PlayerInputControllerFactory: GenericPlayerInputControllerFactory {
    func create(network: GenericTurnSystemNetwork, data: GenericTurnSystemState)
        -> GenericPlayerInputController {
        return PlayerInputController(network: network, data: data)
    }
}
