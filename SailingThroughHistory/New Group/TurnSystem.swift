//
//  File.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class TurnSystem: GenericTurnSystem {

    enum State {
        case ready
        case waitPlayerInput(from: GenericPlayer)
        case playerInput(from: GenericPlayer, endTime: TimeInterval)
        case waitForTurnFinish
        case evaluateMoves(for: GenericPlayer)
        case waitForStateUpdate
        case invalid
    }
    private var state: State {
        get {
            return stateVariable.value
        }

        set {
            stateVariable.value = newValue
        }
    }

    // TODO: Move this into new class
    private var callbacks: [() -> Void] = []
    private var stateVariable: GameVariable<State>
    private var isBlocking = false
    private let isMaster: Bool
    private let deviceId: String
    private var pendingActions = [PlayerAction]()
    private let networkActionQueue = DispatchQueue(label: "com.CS3217.networkActionQueue")

    private let network: RoomConnection
    private var players = [RoomMember]() {
        didSet {

        }
    }

    // for events
    var eventPresets: EventPresets?
    var messages: [GameMessage] = []
    var data: GenericTurnSystemState
    var gameState: GenericGameState {
        return data.gameState
    }

    private var currentPlayer: GenericPlayer? {
        switch state {
        case .playerInput(let player, _):
            return player
        case .waitPlayerInput(let player):
            return player
        default:
            return nil
        }
    }

    init(isMaster: Bool, network: RoomConnection, startingState: GenericGameState, deviceId: String) {
        self.deviceId = deviceId
        self.network = network
        self.isMaster = isMaster
        self.data = TurnSystemState(gameState: startingState, joinOnTurn: 0)
        // TODO: Turn harcoded
        self.stateVariable = GameVariable(value: .ready)
        self.eventPresets = EventPresets(gameState: startingState, turnSystem: self)
        if let eventPresets = self.eventPresets {
            self.data.addEvents(events: eventPresets.getEvents())
        }

        network.subscribeToMembers { [weak self] members in
            self?.players = members
        }
    }

    func startGame() {
        guard let player = getFirstPlayer() else {
            state = .waitForTurnFinish
            return
        }
        state = .waitPlayerInput(from: player)
        data.turnFinished()
    }

    // for testing
    func getState() -> TurnSystem.State {
        return state
    }

    // MARK: - Player actions
    func roll(for player: GenericPlayer) throws -> (Int, [Int]) {
        try checkInputAllowed(from: player)

        if player.hasRolled {
            throw PlayerActionError.invalidAction(message: "Player has already rolled!")
        }
        return player.roll()
    }

    func selectForMovement(nodeId: Int, by player: GenericPlayer) throws {
        try checkInputAllowed(from: player)
        if !player.hasRolled {
            throw PlayerActionError.invalidAction(message: "Player has not rolled!")
        }

        if !player.roll().1.contains(nodeId) {
            throw PlayerActionError.invalidAction(message: "Node is out of range!")
        }

        if nodeId == player.node?.identifier {
            return
        }

        var path = player.getPath(to: nodeId)
        path.removeFirst()
        for (index, transitNode) in path.enumerated() {
            pendingActions.append(.move(toNodeId: transitNode,
                                        isEnd: index == path.indices.last))
        }
        if isSuccess(probability: player.getPirateEncounterChance()) {
            pendingActions.append(.pirate)
        }
    }

    func setTax(for portId: Int, to amount: Int, by player: GenericPlayer) throws {
        try checkInputAllowed(from: player)
        guard let port = gameState.map.nodeIDPair[portId] as? Port else {
            throw PlayerActionError.invalidAction(message: "Port does not exist")
        }
        guard player.team == port.owner else {
            throw PlayerActionError.invalidAction(message: "Player does not own port!")
        }

        pendingActions.append(.setTax(forPortId: portId, taxAmount: amount))
    }

    func buy(itemType: ItemType, quantity: Int, by player: GenericPlayer) throws {
        try checkInputAllowed(from: player)
        guard quantity > 0 else {
            throw PlayerActionError.invalidAction(message: "Bought quantity must be more than 0.")
        }
        if quantity >= 0 {
            try player.buy(itemType: itemType, quantity: quantity)
            pendingActions.append(.buyOrSell(itemType: itemType, quantity: quantity))
        }
    }

    func sell(itemType: ItemType, quantity: Int, by player: GenericPlayer) throws {
        try checkInputAllowed(from: player)
        guard quantity > 0 else {
            throw PlayerActionError.invalidAction(message: "Sold quantity must be more than 0.")
        }
        if quantity >= 0 {
            do {
                try player.sell(itemType: itemType, quantity: quantity)
            } catch let error as BuyItemError {
                throw PlayerActionError.invalidAction(message: error.getMessage())
            }
            pendingActions.append(.buyOrSell(itemType: itemType, quantity: -quantity))
        }
    }

    func purchase(upgrade: Upgrade, by player: GenericPlayer) throws -> InfoMessage? {
        try checkInputAllowed(from: player)
        if !player.canBuyUpgrade() {
            throw PlayerActionError.invalidAction(message: "Not allowed to buy upgrades now.")
        }
        let (success, msg) = player.buyUpgrade(upgrade: upgrade)
        if success {
            pendingActions.append(.purchaseUpgrade(type: upgrade.type))
        }
        return msg
    }

    private func checkInputAllowed(from player: GenericPlayer) throws {
        switch state {
        case .playerInput(let curPlayer, _):
            if player != curPlayer {
                throw PlayerActionError.wrongPhase(message: "Please wait for your turn")
            }
        default:
            throw PlayerActionError.wrongPhase(message: "Aaction called on wrong phase")
        }
    }

    private func playerMove(_ player: GenericPlayer, _ nodeId: Int, isEnd: Bool) -> GameMessage? {
        let previous = player.playerShip.getCurrentNode().name
        player.move(nodeId: nodeId)

        if !isEnd {
            return nil
        }

        let current = player.playerShip.getCurrentNode().name
        return GameMessage.playerAction(name: player.name,
                                        message: " has moved from \(previous) to \(current)")
    }

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
        // some stuff with a sequence
        // for node in nodes (Doesn't check adjacency)
        // player.move(node: node)
        case .setTax(let portId, let taxAmount):
            /// TODO: Handle conflicting set tax
            guard let port = gameState.map.nodeIDPair[portId] as? Port else {
                throw PlayerActionError.invalidAction(message: "Port does not exist")
            }
            guard player.team == port.owner else {
                throw PlayerActionError.invalidAction(message: "Player does not own port!")
            }
            let previous = port.taxAmount.value
            port.taxAmount.value = taxAmount
            return GameMessage.playerAction(
                name: player.name,
                message: " has set the tax for \(port.name) from \(previous) to \(taxAmount)")
        case .buyOrSell(let itemType, let quantity):
            let message = GameMessage.playerAction(
                name: player.name,
                message: " has \(quantity > 0 ? "purchased": "sold") \(quantity) \(itemType.rawValue)")
            if player.deviceId == deviceId {
                return message
            }
            do {
                if quantity >= 0 {
                    try player.buy(itemType: itemType, quantity: quantity)
                } else {
                    try player.sell(itemType: itemType, quantity: -quantity)
                }
            } catch let error as BuyItemError {
                throw PlayerActionError.invalidAction(message: error.getMessage())
            }
            return message
        case .purchaseUpgrade(let upgradeType):
            if player.deviceId == deviceId {
                return GameMessage.playerAction(name: player.name, message: "You moved")
            }
            _ = player.buyUpgrade(upgrade: upgradeType.toUpgrade())
            return GameMessage.playerAction(name: player.name,
                                            message: " has purchased the \(upgradeType.toUpgrade().name)!")
        case .pirate:
            player.playerShip.startPirateChase()
            return GameMessage.playerAction(name: player.name, message: " is chased by pirates!")
        }
    }

    private func setEvents(changeType: ChangeType, events: [TurnSystemEvent]) -> Bool {
        switch changeType {
        case .add:
            return data.addEvents(events: events)
        case .remove:
            return data.removeEvents(events: events)
        case .set:
            return data.setEvents(events: events)
        }
    }

    func watchMasterUpdate(gameState: GenericGameState) {
        switch state {
        case .waitForStateUpdate:
            break
        default:
            return
        }
        startGame()
    }

    func watchTurnFinished(playerActions: [(GenericPlayer, [PlayerAction])]) {
        // make player actions
        if isBlocking {
            return
        }
        switch state {
        case .waitForTurnFinish:
            break
        default:
            return
        }
        isBlocking = true
        for (player, actions) in playerActions {
            let playerActions = evaluateState(player: player, actions: actions)
            messages.append(contentsOf: playerActions)
        }
        updateStateMaster()
        isBlocking = false
    }

    func endTurn() {
        if let currentPlayer = currentPlayer {
            /// TODO: Add error handling. If it throws, then encoding has failed.
            do {
                try network.push(actions: pendingActions, fromPlayer: currentPlayer, forTurnNumbered: data.currentTurn) { _ in
                    /// TODO: Add error handling
                }
            } catch {
                print(error)
            }
            pendingActions = []
        }
        for callback in callbacks {
            callback()
        }
        guard let player = getNextPlayer() else {
            state = .waitForTurnFinish
            let currentTurn = data.currentTurn
            network.subscribeToActions(for: currentTurn) { [weak self] actionPair, error in
                if let _ = error {
                    /// TODO: Error handling
                    return
                }
                self?.processTurnActions(forTurnNumber: currentTurn, playerActionPairs: actionPair)
            }
            state = .waitForTurnFinish
            return
        }
        state = .waitPlayerInput(from: player)
    }

    // Unused
    func endTurnCallback(action: @escaping () -> Void) {
        callbacks.append(action)
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

    private func getFirstPlayer() -> GenericPlayer? {
        return gameState.getPlayers()
            .filter { [weak self] in $0.deviceId == self?.deviceId }
            .first
    }

    func subscribeToState(with callback: @escaping (State) -> Void) {
        stateVariable.subscribe(with: callback)
    }

    func acknoledgeTurnStart() {
        guard let player = currentPlayer else {
            return
        }
        startPlayerInput(from: player)
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

    private func updateStateMaster() {
        state = .waitForStateUpdate
        if isMaster {
            // TODO: Change the typecast
            // TODO: Hook up watch master update with network
            guard let gameState = gameState as? GameState else {
                return
            }
            do {
                try network.push(currentState: gameState) {
                    guard let error = $0 else {
                        return
                    }
                    print(error.localizedDescription)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    private func waitTurnFinish() {

    }

    private func isSuccess(probability: Double) -> Bool {
        return Double(arc4random()) / Double(UINT32_MAX) < probability
    }

    private func processTurnActions(forTurnNumber turnNum: Int, playerActionPairs: [(String, [PlayerAction])]) {
        networkActionQueue.sync { [weak self] in
            guard let self = self else {
                return
            }
            switch self.state {
            case .waitForTurnFinish:
                break
            default:
                return
            }
            if self.data.currentTurn != turnNum {
                return
            }
            let eventResults = data.checkForEvents() // events will run here, non-recursive
            self.messages.append(contentsOf: eventResults)

            for player in self.gameState.getPlayers() where
                playerActionPairs.first(where: { $0.0 == player.name }) == nil {
                    return
            }

            for playerActionPair in playerActionPairs {
                guard let chosenPlayer =
                    self.gameState.getPlayers().first(where: { $0.name == playerActionPair.0 }) else {
                        continue
                }
                let playerActions = self.evaluateState(player: chosenPlayer, actions: playerActionPair.1)
                self.messages.append(contentsOf: playerActions)
                for infoMessage in chosenPlayer.endTurn() {
                    self.messages.append(GameMessage.playerAction(name: chosenPlayer.name, message: infoMessage.message))
                }
            }
            state = .waitForStateUpdate
            // OI
            startGame() // TODO: Remove this
            /*
            guard let player = self.getFirstPlayer() else {
                self.state = .waitForTurnFinish
                return
            }
            state = .waitPlayerInput(from: player)
            */
        }
    }

    private func startPlayerInput(from player: GenericPlayer) {
        let endTime = Date().timeIntervalSince1970 + GameConstants.playerTurnDuration
        let turnNum = data.currentTurn
        DispatchQueue.global().asyncAfter(deadline: .now() + GameConstants.playerTurnDuration) { [weak self] in
            if player == self?.currentPlayer && self?.data.currentTurn == turnNum {
                self?.endTurn()
            }
        }

        self.state = .playerInput(from: player, endTime: endTime)
    }
}
