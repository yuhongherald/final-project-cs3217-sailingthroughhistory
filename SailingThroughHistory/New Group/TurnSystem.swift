//
//  File.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class TurnSystem: GenericTurnSystem {
    private enum State {
        case ready(player: GenericPlayer)
        case waitForTurnFinish
        case waitForStateUpdate
        case invalid
    }
    private var state: State
    private let network: RoomConnection
    private let isMaster: Bool
    private var systemState: GenericTurnSystemState
    private let deviceId: String
    var gameState: GameState {
        return systemState.gameState
    }

    init(isMaster: Bool, network: RoomConnection, startingState: GameState, deviceId: String) {
        self.deviceId = deviceId
        self.network = network
        self.isMaster = isMaster
        self.systemState = TurnSystemState(gameState: startingState)
        self.state = .invalid
        guard let player = getNextPlayer() else {
            fatalError("No players belong on this device/")
        }
        state = .ready(player: player)
    }

    // TODO: Add to protocol and also do a running gamestate
    func startGame() {
        //
    }

    /// Returns false if action is invalid
    func makeAction(for player: GenericPlayer, action: PlayerAction) -> Bool {
        //player.
        switch state {
        case .waitForTurnFinish:
            return false
        default:
            break
        }
        switch action {
        case .changeInventory(changeType: let changeType, money: let money, items: let items):
            // TODO: Discuss player API
            //player.getMaxPurchaseAmount(itemParameter: )
            return false
        case .roll:
            if player.hasRolled {
                return false
            }
            _ = player.roll()
            return true
        case .move(to: let node):
            if !player.hasRolled {
                return false
            }
            if !player.getNodesInRange(roll: player.roll()).contains(node) {
                return false
            }
            player.move(node: node)
            return true
        case .forceMove(to: let node): // quick hack for updating the player's position remotely
            player.move(node: node)
            return true
        case .setTax(for: let port, let taxAmount):
            guard player == port.owner else { // TODO: Fix equality assumption
                return false
            }
        port.taxAmount = taxAmount
        return true
        case .setEvent(changeType: let changeType, events: let events):
            return setEvents(changeType: changeType, events: events)
        }
    }

    private func setEvents(changeType: ChangeType, events: [ReadOnlyEventCondition]) -> Bool {
        switch changeType {
        case .add:
            return false
        case .remove: // TODO: Add support for removing events
            return false
        case .set:
            return false
        }
    }
    // TODO: Fix the gamestate sent back
    func watchMasterUpdate(gameState: GenericGameState) {
        switch state {
        case .waitForTurnFinish:
            return
        default:
            break
        }
    }

    func watchTurnFinished(playerActions: [PlayerAction]) {
        // make player actions
        switch state {
        case .waitForTurnFinish:
            return
        default:
            break
        }
        evaluateState()
        checkForEvents()
        updateStateMaster()
    }

    func endTurn() {
        guard let nextPlayer = getNextPlayer() else {
            return
        }


    }

    func getNextPlayer() -> GenericPlayer? {
        let players = gameState.getPlayers()
            .filter { [weak self] in $0.deviceId == self?.deviceId }
        systemState.currentPlayerIndex += 1
        if !players.indices.contains(systemState.currentPlayerIndex) {
            systemState.currentPlayerIndex = 0
            return nil
        }

        return players[systemState.currentPlayerIndex]
    }

    private func evaluateState() {
        //
    }

    private func checkForEvents() {
        //
    }

    private func updateStateMaster() {
        //
    }

}
