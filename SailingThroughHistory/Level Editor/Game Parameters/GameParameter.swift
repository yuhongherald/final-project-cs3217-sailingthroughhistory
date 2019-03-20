//
//  GameParameter.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GameParameter: Level {
    var itemTypes: ItemParameter
    
    private var upgrades = [Upgrade]()
    private var itemParameters = [ItemParameter]()
    private var storages = [Port: [Item]]()
    private var playerParameters = [PlayerParameter]()
    private var eventParameters = [EventParameter]()
    private var map = Map()

    init() {
        itemTypes = ItemParameter(type: ItemType.opium)
        upgrades = []
        itemParameters = []
        storages = [Port: [Item]]()
        playerParameters = []
        eventParameters = []
        fatalError("Not implemented")
    }

    func getPlayers() -> [Player] {
        return playerParameters.map { $0.getPlayer() }
    }

    func getMap() -> Map {
        return map
    }

    func getItemLocations() -> [Port: [Item]] {
        return storages
    }

    func setItemValue(for item: ItemParameter, from: Port, to: Port) {
        //item.setBuyValue(at: <#T##Port#>, to: <#T##Int#>)
    }
}
