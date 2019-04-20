//
//  TurnSystemNetwork.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class TurnSystemNetwork {
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

    private var currentTurn: Int = 0
    private var data: GenericTurnSystemState
    private var setTaxActions = [Int: (PlayerAction, GenericPlayer, Bool)]()

    private let networkActionQueue = DispatchQueue(label: "com.CS3217.networkActionQueue")
    private let network: RoomConnection
    private let messenger: GameMessenger

    private let deviceId: String
    private let isMaster: Bool

    private var gameState: GenericGameState {
        return data.gameState
    }

    private var players = [RoomMember]() {
        didSet {
            let turn = currentTurn
            network.getTurnActions(for: turn) { [weak self] (actions, _) in
                self?.processNetworkTurnActions(forTurnNumber: turn, playerActionPairs: actions)
            }
            for player in oldValue where players.first(where: { $0.playerName == player.playerName }) == nil {
                self.messenger.messages.append(GameMessage.playerAction(name: player.playerName, message: "has left the game."))
            }
        }
    }

    private var messages: [GameMessage] {
        get {
            return messenger.messages
        }
        set {
            messenger.messages = newValue
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
    var stateVariable: GameVariable<State>

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
    var pendingActions = [PlayerAction]()

    init(roomConnection: RoomConnection, isMaster: Bool, deviceId: String,
         turnSystemState: GenericTurnSystemState, messenger: GameMessenger) {
        self.network = roomConnection
        self.messenger = messenger
        self.stateVariable = GameVariable(value: .ready)
        self.data = turnSystemState
        self.deviceId = deviceId
        self.isMaster = isMaster

        network.subscribeToMembers { [weak self] members in
            self?.players = members
        }
    }

    private func evaluateState(player: GenericPlayer, actions: [PlayerAction])
        -> [GameMessage] {
            var actions = actions
            state = .evaluateMoves(for: player)
            var result = [GameMessage]()
            while !actions.isEmpty {
                do {
                    if let message = try process(action: actions.removeFirst(), for: player) {
                        result.append(message)
                    }
                } catch {
                    print("Invalid action from server, dropping action")
                }
            }
            return result
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

    /// MARK: Private funcs

    /// Throws if action is invalid
    /// For server actions only
    private func process(action: PlayerAction, for player: GenericPlayer) throws -> GameMessage? {
        switch state {
        case .evaluateMoves(for: let currentPlayer):
            if player != currentPlayer {
                throw PlayerActionError.wrongPhase(message: "Evaluate move on wrong player!")
            }
        default:
            throw PlayerActionError.wrongPhase(message: "Make action called on wrong phase")
        }
        switch action {
        case .move(let nodeId, let isEnd):
            return playerMove(player, nodeId, isEnd: isEnd)
        case .forceMove(let nodeId): // quick hack for updating the player's position remotely
            return playerMove(player, nodeId, isEnd: true)
        case .setTax:
            return try register(portTaxAction: action, by: player)
        case .buyOrSell:
            return try handle(tradeAction: action, by: player)
        case .purchaseUpgrade(let upgradeType):
            if player.deviceId == deviceId {
                return GameMessage.playerAction(name: player.name, message: "You moved")
            }
            _ = player.buyUpgrade(upgrade: upgradeType.toUpgrade())
            return GameMessage.playerAction(name: player.name,
                                            message: " has purchased the \(upgradeType.toUpgrade().name)!")
        case .pirate:
            player.playerShip?.startPirateChase()
            return GameMessage.playerAction(name: player.name, message: " is chased by pirates!")
        case .togglePresetEvent(let eventId, let enabled):
            if player.deviceId == deviceId {
                return nil
            }
            guard let event = data.events[eventId] as? PresetEvent else {
                return nil
            }
            event.active = enabled
            return nil
        }
    }
    
    private func handle(tradeAction: PlayerAction, by player: GenericPlayer) throws -> GameMessage? {
        switch tradeAction {
        case .buyOrSell(let itemParameter, let quantity):
            let message = GameMessage.playerAction(
                name: player.name,
                message: " has \(quantity > 0 ? "purchased": "sold") \(quantity) \(itemParameter.rawValue)")
            if player.deviceId == deviceId {
                return message
            }
            do {
                if quantity >= 0 {
                    try player.buy(itemParameter: itemParameter, quantity: quantity)
                } else {
                    try player.sell(itemParameter: itemParameter, quantity: -quantity)
                }
            } catch let error as TradeItemError {
                throw PlayerActionError.invalidAction(message: error.getMessage())
            }
            return message
        default:
            return nil
        }
    }

    private func register(portTaxAction action: PlayerAction, by player: GenericPlayer) throws -> GameMessage? {
        switch action {
        case .setTax(let portId, _):
            guard let port = gameState.map.nodeIDPair[portId] as? Port else {
                throw PlayerActionError.invalidAction(message: "Port does not exist.")
            }
            
            if setTaxActions[portId] != nil {
                setTaxActions[portId] = (action, player, false)
            } else {
                setTaxActions[portId] = (action, player, true)
            }
            
            return .playerAction(name: player.name, message: "Instructed \(port.name) to change tax.")
        default:
            return nil
        }
    }

    private func handleSetTax() {
        for (action, player, success) in setTaxActions.values {
            switch action {
            case .setTax(let portId, let taxAmount):
                guard let port = gameState.map.nodeIDPair[portId] as? Port else {
                    return
                }
                guard player.team == port.owner else {
                    return
                }
                guard success else {
                    self.messages.append(
                        GameMessage.playerAction(name: "",
                                                 message: "Failed to change tax for \(port.name) " +
                            "due to conflicting instructions."))
                    return
                }
                let previous = port.taxAmount.value
                port.taxAmount.value = taxAmount
                self.messages.append(GameMessage.playerAction(
                    name: player.name,
                    message: " has set the tax for \(port.name) from \(previous) to \(taxAmount)"))
            default:
                return
            }
        }
        setTaxActions = Dictionary()
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
                                                                                         message: $0.message)})
            }
        }
        gameState.map.npcs.forEach {
            guard let node = $0.moveToNextNode(map: gameState.map, maxTaxAmount: 2000) else {
                return
            }
            self.messages.append(GameMessage.playerAction(name: "NPC", message: "An npc has moved into \(node.name)"))
        }
        handleSetTax()
        let eventResults = data.checkForEvents() // events will run here, non-recursive
        self.messages.append(contentsOf: eventResults)
        gameState.gameTime.value.addWeeks(4)
        gameState.map.updateWeather(for: gameState.gameTime.value.month)
        gameState.distributeTeamMoney()
        
        updateStateMaster()
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
            commitEndTurn()
            pendingActions = []
        }
        guard let player = getNextPlayer() else {
            waitForTurnFinish()
            return
        }
        state = .waitPlayerInput(from: player)
    }

    private func commitEndTurn() {
        guard let currentPlayer = self.currentPlayer else {
            print("Ending a turn without a player")
            return
        }
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
            guard let gameState = self?.gameState else {
                return
            }
            //assert(gameState.description == networkGameState.description)
        }
    }

    private func playerMove(_ player: GenericPlayer, _ nodeId: Int, isEnd: Bool) -> GameMessage? {
        guard let ship = player.playerShip else {
            return nil
        }
        let previous = ship.node.name
        player.move(nodeId: nodeId)
        
        if !isEnd {
            return nil
        }
        
        let current = ship.node.name
        return GameMessage.playerAction(name: player.name,
                                        message: " has moved from \(previous) to \(current)")
    }
}
