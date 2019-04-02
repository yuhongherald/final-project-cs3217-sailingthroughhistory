//
//  File.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class TurnSystem: GenericTurnSystem {
    private enum State {
        case ready
        case waitForTurnFinish
        case waitForStateUpdate
        case invalid
    }
    private var state: State = .ready

    init(isMaster: Bool) {
        
    }

    // TODO: Add to protocol and also do a running gamestate
    func startGame() {
        //
    }

    /// Returns false if action is invalid
    func makeAction(for player: GenericPlayer, action: PlayerAction) -> Bool {
        //player.
        if state != .waitForTurnFinish {
            return false
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
            guard player.team == port.owner else { // TODO: Fix equality assumption
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
        if state != .waitForStateUpdate {
            return
        }
    }

    func watchTurnFinished(playerActions: [PlayerAction]) {
        // make player actions
        if state != .waitForTurnFinish {
            return
        }
        evaluateState()
        checkForEvents()
        updateStateMaster()
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
