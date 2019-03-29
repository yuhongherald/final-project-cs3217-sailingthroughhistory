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
    private var teams = [Team]()
    private var numOfTurn = 20
    private var timeLimit = 30
    private var map = Map()

    init(teams: String...) {
        var numOfTeam = teams.count
        if numOfTeam < 2 {
            numOfTeam = 2
        }
        for identifier in 0..<numOfTeam {
            var teamName = "Team \(identifier + 1)"
            if identifier < numOfTeam {
                teamName = teams[identifier]
            }
            playerParameters.append(PlayerParameter(name: "\(teamName)-player0", teamName: teamName))
            self.teams.append(Team(name: teamName))
        }
    }

    func getPlayerParameters() -> [PlayerParameter] {
        return playerParameters
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
