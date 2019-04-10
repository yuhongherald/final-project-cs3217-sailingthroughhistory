//
//  GenericLevel.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol GenericLevel {
    var upgrades: [Upgrade] { get }
    var playerParameters: [PlayerParameter] { get set }
    var itemParameters: [ItemParameter] { get set }
    var eventParameters: [EventParameter] { get set }
    var teams: [Team] { get set }
    var numOfTurn: Int { get set }
    var timeLimit: Int { get set }
    var map: Map { get }

    init(map: Map, teams: [String])
}
