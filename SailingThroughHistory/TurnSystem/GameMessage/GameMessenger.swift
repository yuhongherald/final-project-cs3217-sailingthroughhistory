//
//  GameMessenger.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GameMessenger: class {
    var messages: [GameMessage] { get set }
}
