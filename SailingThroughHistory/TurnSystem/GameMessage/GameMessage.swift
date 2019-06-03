//
//  GameMessage.swift
//  SailingThroughHistory
//
//  Created by Herald on 11/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * An enum that stores information on an event that has happened in the game.
 */
enum GameMessage {
    case playerAction(name: String, message: String)
    case event(name: String, message: String)
}
