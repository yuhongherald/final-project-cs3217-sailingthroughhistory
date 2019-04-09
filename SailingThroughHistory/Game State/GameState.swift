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
    var itemParameters: [GameVariable<ItemParameter>]

    private(set) var map: Map
    private var teams = [Team]()
    private var players = [GenericPlayer]()
    private var speedMultiplier = 1.0

    private var playerTurnOrder = [GenericPlayer]()

    init(baseYear: Int, level: GenericLevel, players: [RoomMember]) {
        //TODO
        gameTime = GameVariable(value: GameTime())
        teams = level.teams
        //initializePlayersFromParameters(parameters: level.playerParameters)
        map = level.map
        itemParameters = [GameVariable<ItemParameter>]()
        for itemParameter in level.itemParameters {
            itemParameters.append(GameVariable<ItemParameter>(value: itemParameter))
        }
        initializePlayers(from: level.playerParameters, for: players)
        self.players.forEach {
            $0.addShipsToMap(map: map)
        }
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
    }

    private enum CodingKeys: String, CodingKey {
        case gameTime
        case map
        case itemParameters
        case teams
        case players
        case speedMultiplier
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

    private func initializePlayers(from parameters: [PlayerParameter], for roomPlayers: [RoomMember]) {
        players.removeAll()
        for roomPlayer in roomPlayers {
            let parameter = parameters.first {
                $0.getTeam().name == roomPlayer.teamName
            }
            print(parameters.map { $0.getTeam().name })
            guard let unwrappedParam = parameter, roomPlayer.hasTeam else {
                preconditionFailure("Player has invalid team.")
            }

            let node: Node

            if let startingNode = unwrappedParam.getStartingNode() {
                node = startingNode
            } else {
                guard let defaultNode = map.getNodes().first else {
                    fatalError("No nodes to start from")
                }

                node = defaultNode
            }

            let team = unwrappedParam.getTeam()
            if !teams.contains(where: {$0.name == team.name}) {
                teams.append(team)
            }
            let player = Player(name: roomPlayer.playerName, team: team, map: map,
                                node: node, deviceId: roomPlayer.deviceId)
            player.updateMoney(to: unwrappedParam.getMoney())
            player.gameState = self
            players.append(player)
        }
    }
}
