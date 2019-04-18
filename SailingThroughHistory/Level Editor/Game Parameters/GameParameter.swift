//
//  GameParameter.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GameParameter: GenericLevel, Codable {
    let maxTaxAmount = 2000
    let defaultTaxAmount = 1000
    var upgrades: [Upgrade] = [BiggerShipUpgrade(), FasterShipUpgrade(), BiggerSailsUpgrade(), MercernaryUpgrade()]

    var playerParameters = [PlayerParameter]()
    var itemParameters = [ItemParameter]()
    var teams: [Team]
    var numOfTurn = GameConstants.numOfTurn
    var timeLimit = Int(GameConstants.playerTurnDuration)
    var map: Map

    required init(map: Map, teams: [String]) {
        self.map = map
        self.teams = teams.map { Team(name: $0) }
        self.playerParameters = teams.map { PlayerParameter(name: "\($0)-player", teamName: $0, node: nil) }
        ItemType.allCases.forEach {
            self.itemParameters.append(ItemParameter(itemType: $0,
                                                     displayName: $0.rawValue,
                                                     weight: $0.getUnitWeight(),
                                                     isConsumable: true))
        }
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        playerParameters = try values.decode([PlayerParameter].self, forKey: .playerParameters)
        itemParameters = try values.decode([ItemParameter].self, forKey: .itemParameters)
        teams = try values.decode([Team].self, forKey: .teams)
        numOfTurn = try values.decode(Int.self, forKey: .numOfTurn)
        timeLimit = try values.decode(Int.self, forKey: .timeLimit)
        map = try values.decode(Map.self, forKey: .map)
        let upgradeTypes = try values.decode([UpgradeType].self, forKey: .upgrades)
        upgrades = upgradeTypes.map { $0.toUpgrade() }

        for node in map.getNodes() {
            if let index = teams.map({ $0.startId }).firstIndex(of: node.identifier) {
                teams[index].startingNode = node
            }
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
        try container.encode(teams, forKey: .teams)
        try container.encode(numOfTurn, forKey: .numOfTurn)
        try container.encode(timeLimit, forKey: .timeLimit)
        try container.encode(map, forKey: .map)
        let upgradeTypes = upgrades.map { $0.type }
        try container.encode(upgradeTypes, forKey: .upgrades)
    }

    private enum CodingKeys: String, CodingKey {
        case playerParameters
        case itemParameters
        case teams
        case numOfTurn
        case timeLimit
        case map
        case upgrades
    }
}
