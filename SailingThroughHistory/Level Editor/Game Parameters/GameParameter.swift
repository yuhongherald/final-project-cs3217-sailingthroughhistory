//
//  GameParameter.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GameParameter: GenericLevel, Codable {
    var playerParameters = [PlayerParameter]()
    var eventParameters = [EventParameter]()
    var teams = [Team]()
    var numOfTurn = GameConstants.numOfTurn
    var timeLimit = Int(GameConstants.playerTurnDuration)
    var map: Map

    init(map: Map) {
        self.map = map
    }

    func getPlayerParameters() -> [PlayerParameter] {
        return playerParameters
    }

    func getPlayers() -> [GenericPlayer] {
        var players = [GenericPlayer]()
        playerParameters.forEach {
            guard let node = $0.getStartingNode() else {
                NSLog("\($0.getName()) fails to be constructed because of loss of starting node.")
                return
            }
            let team = $0.getTeam()
            teams.append(team)
            players.append(Player(name: $0.getName(), team: team, node: node))
        }
        return players
    }

    func getMap() -> Map {
        return map
    }

    func getNumOfTurn() -> Int {
        return numOfTurn
    }

    func getTimeLimit() -> Int {
        return timeLimit
    }

    func setNumOfTurn(_ num: Int) {
        self.numOfTurn = num
    }

    func setTimeLimit(_ num: Int) {
        self.timeLimit = num
    }
}
