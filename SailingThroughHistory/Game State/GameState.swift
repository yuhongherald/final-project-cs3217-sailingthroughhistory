//
//  GameState.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Represents a Game State that interacts with TurnSystem and Level.
import Foundation

class GameState: GenericGameState {
    var gameTime: GameVariable<GameTime>
    var gameObjects: [GameObject] {
        return map.gameObjects.value
    }
    let maxTaxAmount: Int
    let availableUpgrades: [Upgrade]
    var itemParameters: [GameVariable<ItemParameter>]
    let numTurns: Int

    private(set) var map: Map
    private var teams = [Team]()
    private var players = [GenericPlayer]()
    private var speedMultiplier = 1.0

    private var playerTurnOrder = [GenericPlayer]()

    /// Creates a GameState given a baseYear of the game time, a level to load
    /// information from and a list of players.
    init(baseYear: Int, level: GenericLevel, players: [RoomMember]) {
        gameTime = GameVariable(value: GameTime(baseYear: baseYear))
        teams = level.teams
        map = level.map
        availableUpgrades = level.upgrades
        maxTaxAmount = level.maxTaxAmount
        itemParameters = [GameVariable<ItemParameter>]()
        for itemParameter in level.itemParameters {
            itemParameters.append(GameVariable<ItemParameter>(value: itemParameter))
        }
        numTurns = level.numOfTurn
        initializePlayers(from: level.playerParameters, for: players)
        self.players.forEach { player in
            player.map = map
            player.addShipsToMap(map: map)
            player.gameState = self
        }
        initializePortTaxes(to: level.defaultTaxAmount)
        initializeNPCs(amount: players.count)
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
        try players = values.decode([PlayerWithType].self, forKey: .players).map { $0.player }
        try speedMultiplier = values.decode(Double.self, forKey: .speedMultiplier)
        try numTurns = values.decode(Int.self, forKey: .numTurns)

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
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gameTime.value, forKey: .gameTime)
        try container.encode(map, forKey: .map)
        let itemParameters = self.itemParameters.map {
            return $0.value
        }
        try container.encode(numTurns, forKey: .numTurns)
        try container.encode(itemParameters, forKey: .itemParameters)
        try container.encode(teams, forKey: .teams)
        try container.encode(players.map { PlayerWithType(from: $0) }, forKey: .players)
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
        case numTurns
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

    func distributeTeamMoney() {
        var teamPlayers = [Team: [GenericPlayer]]()
        for player in players {
            guard let team = player.team else {
                continue
            }
            teamPlayers[team, default: []].append(player)
        }
        for (team, players) in teamPlayers {
            let moneyPerPlayer = team.money.value / players.count
            for player in players {
                player.updateMoney(by: moneyPerPlayer)
            }
            team.money.value = 0
        }
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
                let player = GameMaster(name: roomPlayer.playerName, deviceId: roomPlayer.deviceId)
                players.append(player)
                continue
            }
            let parameter = parameters.first {
                $0.getTeam().name == roomPlayer.teamName
            }
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

            let itemsConsumed = unwrappedParam.itemsConsumed.map({ itemParameterTupleToItem(tuple: $0) })
                .compactMap({ $0 })
            let startingItems = unwrappedParam.startingItems.map({ itemParameterTupleToItem(tuple:
                $0) }).compactMap({ $0 })
            let player = Player(name: String(roomPlayer.playerName.prefix(8)),
                                team: team, map: map, node: node, itemsConsumed: itemsConsumed,
                                startingItems: startingItems, deviceId: roomPlayer.deviceId)
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
            map.addGameObject(gameObject: NPC(node: node, maxTaxAmount: maxTaxAmount))
        }
    }

    private func itemParameterTupleToItem(tuple: (ItemParameter, Int)) -> GenericItem? {
        guard let itemParameter = itemParameters.first(where: { $0.value == tuple.0 })?.value else {
            return nil
        }
        let item = Item(itemParameter: itemParameter, quantity: tuple.1)
        return item
    }

    /// Used to decode the various types of players: normal Player, spectators that
    /// can only observe the game, and GameMasters that can manipulate the game with
    /// events but cannot perform normal player actions.
    struct PlayerWithType: Codable {
        let type: PlayerType
        let player: GenericPlayer

        init(from player: GenericPlayer) {
            if player is Player {
                self.type = .player
            } else if player is GameMaster {
                self.type = .gameMaster
            } else {
                fatalError("Unsupported player type.")
            }
            self.player = player
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(PlayerType.self, forKey: .type)
            switch self.type {
            case .gameMaster:
                self.player = try container.decode(GameMaster.self, forKey: .player)
            case .player:
                self.player = try container.decode(Player.self, forKey: .player)
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            if let master = player as? GameMaster {
                try container.encode(master, forKey: .player)
            } else if let player = player as? Player {
                try container.encode(player, forKey: .player)
            }
        }

        enum CodingKeys: String, CodingKey {
            case type
            case player
        }
    }

    enum PlayerType: String, Codable {
        case gameMaster
        case player
    }
}

// String convertible
extension GameState {
    var description: String {
        guard let string = try? JSONEncoder().encode(self).hashed(.sha256) else {
            return ""
        }
        return string ?? ""
    }
}
