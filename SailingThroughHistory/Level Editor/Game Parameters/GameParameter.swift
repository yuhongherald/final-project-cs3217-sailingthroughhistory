//
//  GameParameter.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GameParameter: Codable {
    private var playerParameters = [PlayerParameter]()
    private var eventParameters = [EventParameter]()
    private var map = Map()

    init(numOfPlayer: Int) {
        for id in 0..<numOfPlayer {
            playerParameters.append(PlayerParameter(name: "player\(id)"))
        }
    }

    func getPlayerParameters() -> [PlayerParameter] {
        return playerParameters
    }

    func getMap() -> Map {
        return map
    }
}
