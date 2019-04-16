//
//  GameState.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GameState: GenericGameState {
    var gameTime: GameVariable<GameTime>
    var gameObjects: [GameObject] {
        return map.gameObjects.value
    }
    let maxTaxAmount: Int
    let availableUpgrades: [Upgrade]
    var itemParameters: [GameVariable<ItemParameter>]

    private(set) var map: Map
    private var teams = [Team]()
    private var players = [GenericPlayer]()
    private var speedMultiplier = 1.0

    private var playerTurnOrder = [GenericPlayer]()

    init(baseYear: Int, level: GenericLevel, players: [RoomMember]) {
        gameTime = GameVariable(value: GameTime(baseYear: baseYear))
        teams = level.teams
        //initializePlayersFromParameters(parameters: level.playerParameters)
        map = level.map
        availableUpgrades = level.upgrades
        maxTaxAmount = level.maxTaxAmount
        itemParameters = [GameVariable<ItemParameter>]()
        for itemParameter in level.itemParameters {
            itemParameters.append(GameVariable<ItemParameter>(value: itemParameter))
        }
        initializePlayers(from: level.playerParameters, for: players)
        self.players.forEach { player in
            player.map = map
            player.addShipsToMap(map: map)
            player.gameState = self
        }
        initializePortTaxes(to: level.defaultTaxAmount)
        initializeNPCs(amount: level.numNPC)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try gameTime = GameVariable(value: values.decode(GameTime.self, forKey: .gameTime))
        try map = values.decode(Map.self, forKey: .map)
        let itemParameters = try values.decode([ItemParameter].self, forKey: .itemParameters)
        self.itemParameters = [GameVariable<ItemParameter>]()
        for itemParameter in itemParameters {
            self.itemParameters.append(GameVariable<ItemParameter>(value: itemParameter))
        }

        try teams = values.decode([Team].self, forKey: .teams)
        try players = values.decode([Player].self, forKey: .players)
        try speedMultiplier = values.decode(Double.self, forKey: .speedMultiplier)

        let upgradeTypes = try values.decode([UpgradeType].self, forKey: .availableUpgrades)
        availableUpgrades = upgradeTypes.map { $0.toUpgrade() }
        maxTaxAmount = try values.decode(Int.self, forKey: .maxTaxAmount)

        for player in players {
            player.map = map
            player.addShipsToMap(map: map)
            player.gameState = self
        }
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
        guard let players = players as? [Player] else {
            return
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gameTime.value, forKey: .gameTime)
        try container.encode(map, forKey: .map)
        let itemParameters = self.itemParameters.map {
            return $0.value
        }
        try container.encode(itemParameters, forKey: .itemParameters)
        try container.encode(teams, forKey: .teams)
        try container.encode(players, forKey: .players)
        try container.encode(speedMultiplier, forKey: .speedMultiplier)
        let upgradeTypes = availableUpgrades.map { $0.type }
        try container.encode(upgradeTypes, forKey: .availableUpgrades)
        try container.encode(maxTaxAmount, forKey: .maxTaxAmount)
    }

    private enum CodingKeys: String, CodingKey {
        case gameTime
        case map
        case itemParameters
        case teams
        case players
        case speedMultiplier
        case availableUpgrades
        case maxTaxAmount
    }

    func getPlayers() -> [GenericPlayer] {
        return players
    }

    func getNextPlayer() -> GenericPlayer? {
        let nextPlayer = playerTurnOrder.removeFirst()
        nextPlayer.startTurn(speedMultiplier: speedMultiplier, map: map)
        return nextPlayer
    }

    func startNextTurn(speedMultiplier: Double) {
        self.speedMultiplier = speedMultiplier
        playerTurnOrder.removeAll()
        for player in players {
            playerTurnOrder.append(player)
        }
    }

    func endGame() {
    }

    func getTeamMoney() -> [Team: Int] {
        var result = [Team: Int]()
        for player in players {
            guard let team = player.team else {
                continue
            }
            result[team] = (result[team] ?? 0) + player.money.value
        }

        return result
    }

    private func initializePlayers(from parameters: [PlayerParameter], for roomPlayers: [RoomMember]) {
        players.removeAll()
        for roomPlayer in roomPlayers {
            if roomPlayer.isGameMaster {
                let player = GameMaster(name: roomPlayer.playerName)
                players.append(player)
                return
            }
            let parameter = parameters.first {
                $0.getTeam().name == roomPlayer.teamName
            }
            print(parameters.map { $0.getTeam().name })
            guard let unwrappedParam = parameter, roomPlayer.hasTeam else {
                preconditionFailure("Player has invalid team.")
            }

            var team = unwrappedParam.getTeam()
            if let storedTeam = teams.first(where: {$0.name == team.name}) {
                team = storedTeam
            } else {
                teams.append(team)
            }

            let node: Node
            if let startingNode = team.startingNode {
                node = startingNode
            } else {
                guard let defaultNode = map.getNodes().first else {
                    fatalError("No nodes to start from")
                }
                node = defaultNode
            }

            let itemsConsumed = unwrappedParam.itemsConsumed.map({ itemTypeTupleToItem(tuple: $0) }).compactMap({ $0 })
            let startingItems = unwrappedParam.startingItems.map({ itemTypeTupleToItem(tuple:
                $0) }).compactMap({ $0 })
            let player = Player(name: String(roomPlayer.playerName.prefix(5)),
                                team: team, map: map, node: node, itemsConsumed: itemsConsumed, startingItems: startingItems, deviceId: roomPlayer.deviceId)
            player.updateMoney(to: unwrappedParam.getMoney())
            player.gameState = self
            players.append(player)
        }
    }

    private func initializePortTaxes(to amount: Int) {
        for node in map.getNodes() {
            guard let port = node as? Port else {
                continue
            }
            port.taxAmount.value = amount
        }
    }

    private func initializeNPCs(amount: Int) {
        guard let node = map.getNodes().first else {
            return
        }
        map.removeAllNpcs()
        for _ in 0..<amount {
            map.addGameObject(gameObject: NPC(node: node))
        }
    }

    private func itemTypeTupleToItem(tuple: (ItemType, Int)) -> GenericItem? {
        guard let itemParameter = itemParameters.first(where: { $0.value.itemType == tuple.0 })?.value else {
            return nil
        }
        let item = Item(itemParameter: itemParameter, quantity: tuple.1)
        return item
    }
}
