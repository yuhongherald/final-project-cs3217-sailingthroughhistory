//
//  TurnSystemNetwork.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

/**
 * The default implementation of GenericTurnSystemNetwork, specific for RoomConnections.
 */
class TurnSystemNetwork: GenericTurnSystemNetwork {
    enum State {
        case ready
        case waitPlayerInput(from: GenericPlayer)
        case playerInput(from: GenericPlayer, endTime: TimeInterval)
        case waitForTurnFinish
        case evaluateMoves(for: GenericPlayer)
        case waitForStateUpdate
        case invalid
        case finished(winner: Team?)
    }

    var pendingActions = [PlayerAction]()

    let playerActionAdapter: GenericPlayerActionAdapter
    let stateVariable: GameVariable<State>
    let networkInfo: NetworkInfo
    let data: GenericTurnSystemState
    let networkActionQueue = DispatchQueue(label: "com.CS3217.networkActionQueue")
    let network: RoomConnection

    var currentTurn: Int {
        return data.currentTurn
    }

    var setTaxActions: [Int: (PlayerAction, GenericPlayer, Bool)] {
        get {
            return networkInfo.setTaxActions
        }
        set {
            networkInfo.setTaxActions = newValue
        }
    }
    var deviceId: String {
        return networkInfo.deviceId
    }
    var isMaster: Bool {
        return networkInfo.isMaster
    }

    var gameState: GenericGameState {
        return data.gameState
    }

    var players = [RoomMember]() {
        didSet {
            let turn = currentTurn
            network.getTurnActions(for: turn) { [weak self] (actions, _) in
                self?.processNetworkTurnActions(forTurnNumber: turn, playerActionPairs: actions)
            }
            for player in oldValue where players.first(where: { $0.playerName == player.playerName }) == nil {
                self.messages.append(GameMessage.playerAction(name: player.playerName, message: "has left the game."))
            }
        }
    }

    var messages: [GameMessage] {
        get {
            return data.messages
        }
        set {
            data.messages = newValue
        }
    }

    var state: State {
        get {
            return stateVariable.value
        }

        set {
            stateVariable.value = newValue
        }
    }

    var currentPlayer: GenericPlayer? {
        switch state {
        case .playerInput(let player, _):
            return player
        case .waitPlayerInput(let player):
            return player
        default:
            return nil
        }
    }

    init(roomConnection: RoomConnection,
         playerActionAdapterFactory: GenericPlayerActionAdapterFactory,
         networkInfo: NetworkInfo,
         turnSystemState: GenericTurnSystemState) {
        self.network = roomConnection
        self.data = turnSystemState
        self.stateVariable = GameVariable<State>(value: .ready)
        self.networkInfo = networkInfo
        self.playerActionAdapter = playerActionAdapterFactory.create(
            stateVariable: self.stateVariable,
            networkInfo: networkInfo,
            data: turnSystemState)

        network.subscribeToMembers { [weak self] members in
            self?.players = members
        }
    }

    func getNextPlayer() -> GenericPlayer? {
        let players = gameState.getPlayers()
            .filter { [weak self] in $0.deviceId == self?.deviceId }
        guard let currentPlayer = currentPlayer,
            let currentIndex = players.firstIndex(where: { $0 == currentPlayer }) else {
                return players.first
        }

        let nextIndex = currentIndex + 1

        if !players.indices.contains(nextIndex) {
            return nil
        }

        return players[nextIndex]
    }

    func getFirstPlayer() -> GenericPlayer? {
        return gameState.getPlayers()
            .filter { [weak self] in $0.deviceId == self?.deviceId }
            .first
    }

    func processNetworkTurnActions(forTurnNumber turnNum: Int, playerActionPairs: [(String, [PlayerAction])]) {
        switch state {
        case .waitForTurnFinish:
            break
        default:
            return
        }
        if currentTurn != turnNum {
            return
        }
        for player in players where
            playerActionPairs.first(where: { player.playerName.hasPrefix($0.0) }) == nil {
                return
        }

        
    }

    func waitForTurnFinish() {
        state = .waitForTurnFinish
        let currentTurn = self.currentTurn
        network.subscribeToActions(for: currentTurn) { [weak self] actionPair, _ in
            self?.processTurnActions(forTurnNumber: currentTurn, playerActionPairs: actionPair)
        }
    }

    func endTurn() {
        if let currentPlayer = currentPlayer {
            commitEndTurn(currentPlayer)
            pendingActions = []
        }
        guard let player = getNextPlayer() else {
            waitForTurnFinish()
            return
        }
        state = .waitPlayerInput(from: player)
    }

    /// MARK: Private funcs
    private func evaluateState(player: GenericPlayer, actions: [PlayerAction])
        -> [GameMessage] {
            var actions = actions
            state = .evaluateMoves(for: player)
            var result = [GameMessage]()
            while !actions.isEmpty {
                do {
                    if let message = try playerActionAdapter.process(action: actions.removeFirst(), for: player) {
                        result.append(message)
                    }
                } catch {
                    print("Invalid action from server, dropping action")
                }
            }
            return result
    }

    private func processTurnActions(forTurnNumber turnNum: Int, playerActionPairs: [(String, [PlayerAction])]) {
        networkActionQueue.sync { [weak self] in
            self?.processNetworkTurnActions(forTurnNumber: turnNum, playerActionPairs: playerActionPairs)
        }
        for playerActionPair in playerActionPairs {
            guard let chosenPlayer =
                self.gameState.getPlayers().first(where: { $0.name == playerActionPair.0 }) else {
                    continue
            }
            let playerActions = self.evaluateState(player: chosenPlayer, actions: playerActionPair.1)
            self.messages.append(contentsOf: playerActions)
            let messages = chosenPlayer.endTurn()
            if chosenPlayer.deviceId == deviceId {
                self.messages.append(contentsOf: messages.map { GameMessage.playerAction(name: chosenPlayer.name,
                                                                             message: $0.getMessage())})
            }
        }
        gameState.map.npcs.forEach {
            guard let node = $0.moveToNextNode(map: gameState.map) else {
                return
            }
            self.messages.append(GameMessage.playerAction(name: "NPC", message: "An npc has moved into \(node.name)"))
        }
        playerActionAdapter.handleSetTax()
        let eventResults = data.checkForEvents() // events will run here, non-recursive
        self.messages.append(contentsOf: eventResults)
        gameState.gameTime.value.addWeeks(4)
        gameState.map.updateWeather(for: gameState.gameTime.value.month)
        gameState.distributeTeamMoney()

        updateStateMaster()
    }

    private func commitEndTurn(_ currentPlayer: GenericPlayer) {
        let currentTurn = self.currentTurn
        let pendingActions = self.pendingActions
        do {
            try network.push(
                actions: pendingActions, fromPlayer: currentPlayer,
                forTurnNumbered: currentTurn) { [weak self] error in
                    guard let self = self, error != nil else {
                        return
                    }
                    /// Usually firebase will resend after internet connection is re-established,
                    /// but we resend it just in-case
                    try? self.network.push(actions: pendingActions, fromPlayer: currentPlayer,
                                           forTurnNumbered: currentTurn) { _ in }
            }
        } catch {
            fatalError("Unable to encode actions.")
        }
    }

    private func updateStateMaster() {
        state = .waitForStateUpdate
        if isMaster {
            guard let gameState = gameState as? GameState else {
                return
            }
            let currentTurn = self.currentTurn
            do {
                try network.push(currentState: gameState, forTurn: currentTurn) {
                    guard let error = $0 else {
                        return
                    }
                    print(error.localizedDescription)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        /// The game state parameter is ignored for now, validation can be added here
        network.subscribeToMasterState(for: currentTurn) { [weak self] networkGameState in
            self?.data.turnFinished()
            if let data = self?.data, let gameState = self?.gameState {
                if data.currentTurn >= gameState.numTurns {
                    let winner = gameState.getTeamMoney().max { (first, second) -> Bool in
                        return first.value < second.value
                        }?.key
                    self?.state = .finished(winner: winner)
                    return
                }
            }
            guard let player = self?.getFirstPlayer() else {
                self?.state = .waitForTurnFinish
                return
            }
            self?.state = .waitPlayerInput(from: player)
            guard (self?.gameState) != nil else {
                return
            }
            //assert(gameState.description == networkGameState.description)
        }
    }
}
