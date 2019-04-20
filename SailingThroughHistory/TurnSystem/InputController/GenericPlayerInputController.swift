//
//  GenericPlayerInputController.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericPlayerInputController {
    func checkInputAllowed(from player: GenericPlayer) throws
    func startPlayerInput(from player: GenericPlayer)
}
