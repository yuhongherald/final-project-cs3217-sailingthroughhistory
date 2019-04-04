//
//  File.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class TurnSystem: GenericTurnSystem {
    private static let turnDuration = 120

    enum State {
        case ready
        case playerInput(from: GenericPlayer, endTime: TimeInterval)
        case waitForTurnFinish
        case evaluateMoves(for: GenericPlayer)
        case waitForStateUpdate
        case invalid
    }

    private var callbacks: [() -> Void] = []
    private var state: State {
        get {
            return stateVariable.value
        }

        set {
            stateVariable.value = newValue
        }
    }
    private var stateVariable: GameVariable<State>
    private let network: RoomConnection
    private var isBlocking = false
    private var players = [RoomMember]() {
        didSet {

        }
    }
    private let isMaster: Bool
    var data: GenericTurnSystemState
    private let deviceId: String
    private var pendingActions = [PlayerAction]()
    var gameState: GenericGameState {
        return data.gameState
    }
    private var currentPlayer: GenericPlayer? {
        switch state {
        case .playerInput(let player, _):
            return player
        default:
            return nil
        }
    }
    private let networkActionQueue = DispatchQueue(label: "com.CS3217.networkActionQueue")

    init(isMaster: Bool, network: RoomConnection, startingState: GenericGameState, deviceId: String) {
        self.deviceId = deviceId
        self.network = network
        self.isMaster = isMaster
        self.data = TurnSystemState(gameState: startingState, joinOnTurn: 0)
        // TODO: Turn harcoded
        self.stateVariable = GameVariable(value: .ready)
        network.subscribeToMembers { [weak self] members in
            self?.players = members
        }

    }

    func startGame() {
        guard let player = getNextPlayer() else {
            state = .waitForTurnFinish
            return
        }
        startPlayerInput(from: player)
    }

    // for testing
    func getState() -> TurnSystem.State {
        return state
    }

    // MARK : - Player actions
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
        var path = player.getPath(to: nodeId)
        path.removeFirst()
        for transitNode in path {
            pendingActions.append(.move(toNodeId: transitNode))
        }
        pendingActions.append(.move(toNodeId: nodeId))
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
        guard let itemParameter = gameState.itemParameters.first(where: {$0.itemType == itemType}) else {
            throw PlayerActionError.invalidAction(message: "Item type does not exist")
        }
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

    /// Throws if action is invalid
    /// For server actions only
    func process(action: PlayerAction, for player: GenericPlayer) throws {
        switch state {
        case .evaluateMoves(for: let currentPlayer):
            if player != currentPlayer {
                throw PlayerActionError.wrongPhase(message: "Evaluate move on wrong player!")
            }
        default:
            throw PlayerActionError.wrongPhase(message: "Make action called on wrong phase")
        }
        switch action {
        case .move(let nodeId):
            player.move(nodeId: nodeId)
        case .forceMove(let nodeId): // quick hack for updating the player's position remotely
            player.move(nodeId: nodeId)
        // some stuff with a sequence
        // for node in nodes (Doesn't check adjacency)
        // player.move(node: node)
        case .setTax(let portId, let taxAmount):
            /// TODO: Handle conflicting set tax
            guard let port = gameState.map.nodeIDPair[portId] as? Port else {
                throw PlayerActionError.invalidAction(message: "Port does not exist")
            }
            guard player.team == port.owner else { // TODO: Fix equality assumption
                throw PlayerActionError.invalidAction(message: "Player does not own port!")
            }
            port.taxAmount = taxAmount
        case .buyOrSell(let itemType, let quantity):
            guard let itemParameter = gameState.itemParameters.first(where: {$0.itemType == itemType}) else {
                throw PlayerActionError.invalidAction(message: "Item type does not exist")
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
            // TODO: Return the eval from buying
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
            evaluateState(player: player, actions: actions)
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
                if let error = error {
                    /// TODO: Error handling
                    return
                }
                self?.processTurnActions(forTurnNumber:currentTurn, playerActionPairs: actionPair)
            }
            return
        }

        startPlayerInput(from: player)

    }

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

    private func evaluateState(player: GenericPlayer, actions: [PlayerAction]) {
        var actions = actions
        state = .evaluateMoves(for: player)
        while !actions.isEmpty {
            while data.checkForEvents() {
            }
            do {
                try process(action: actions.removeFirst(), for: player)
            } catch {
                print("Invalid action from server, dropping action")
            }
        }
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

            for player in self.gameState.getPlayers() where
                playerActionPairs.first(where: { $0.0 == player.name }) == nil {
                    return
            }

            for playerActionPair in playerActionPairs {
                guard let chosenPlayer =
                    self.gameState.getPlayers().first(where: { $0.name == playerActionPair.0 }) else {
                        continue
                }
                self.evaluateState(player: chosenPlayer, actions: playerActionPair.1)
                chosenPlayer.endTurn()
            }

            self.data.turnFinished()

            guard let player = self.getFirstPlayer() else {
                self.state = .waitForTurnFinish
                return
            }
            startPlayerInput(from: player)
        }
    }

    private func startPlayerInput(from player: GenericPlayer) {
        let endTime = NSTimeIntervalSince1970 + 120
        _ = Timer(fire: Date(timeIntervalSince1970: NSTimeIntervalSince1970 + 120), interval: 0, repeats: false) { [weak self] _ in
            self?.endTurn()
        }

        self.state = .playerInput(from: player, endTime: endTime)
    }
}
