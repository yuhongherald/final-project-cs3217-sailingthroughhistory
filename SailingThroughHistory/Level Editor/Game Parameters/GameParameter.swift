//
//  GameParameter.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GameParameter: Level {
    private var upgrades = [Upgrade]()
    private var itemParameters = Set<ItemParameter>()
    private var storages = [Port: [Item]]()
    private var playerParameters = [PlayerParameter]()
    private var eventParameters = [EventParameter]()
    private var map = Map()

    func getPlayers() -> [Player] {
        return playerParameters.map { $0.getPlayer() }
    }

    func getMap() -> Map {
        return map
    }

    func getItemLocations() -> [Port: [Item]] {
        return storages
    }
}
