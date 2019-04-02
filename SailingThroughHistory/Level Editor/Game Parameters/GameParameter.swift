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
    var itemParameters = [ItemParameter]()
    var eventParameters = [EventParameter]()
    var teams = [Team]()
    var numOfTurn = GameConstants.numOfTurn
    var timeLimit = Int(GameConstants.playerTurnDuration)
    var map: Map

    required init(map: Map, teams: [String]) {
        self.map = map
        for teamName in teams {
            self.teams.append(Team(name: teamName))
            self.playerParameters.append(PlayerParameter(name: "\(teamName)-player", teamName: teamName, node: nil))
        }
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        playerParameters = try values.decode([PlayerParameter].self, forKey: .playerParameters)
        itemParameters = try values.decode([ItemParameter].self, forKey: .itemParameters)
        eventParameters = try values.decode([EventParameter].self, forKey: .eventParameters)
        teams = try values.decode([Team].self, forKey: .teams)
        numOfTurn = try values.decode(Int.self, forKey: .numOfTurn)
        timeLimit = try values.decode(Int.self, forKey: .timeLimit)
        map = try values.decode(Map.self, forKey: .map)

        for node in map.getNodes() {
            guard let port = node as? Port else {
                continue
            }
            port.assignOwner(teams.first(where: { team in
                team.name == port.ownerName
            }))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(playerParameters, forKey: .playerParameters)
        try container.encode(itemParameters, forKey: .itemParameters)
        try container.encode(eventParameters, forKey: .eventParameters)
        try container.encode(teams, forKey: .teams)
        try container.encode(numOfTurn, forKey: .numOfTurn)
        try container.encode(timeLimit, forKey: .timeLimit)
        try container.encode(map, forKey: .map)
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

    private enum CodingKeys: String, CodingKey {
        case playerParameters
        case itemParameters
        case eventParameters
        case teams
        case numOfTurn
        case timeLimit
        case map
    }
}
