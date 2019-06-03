//
//  GameMessenger.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A class that stores GameMessages, meant to be displayed.
 */
protocol GameMessenger: class {
    /// Returns the list of messages it wants to display.
    var messages: [GameMessage] { get set }
}
