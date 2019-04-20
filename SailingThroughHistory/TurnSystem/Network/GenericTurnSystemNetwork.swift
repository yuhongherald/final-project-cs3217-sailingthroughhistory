//
//  GenericTurnSystemNetwork.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericTurnSystemNetwork: class {
    var pendingActions: [PlayerAction] { get set }
    var stateVariable: GameVariable<TurnSystemNetwork.State> { get }
    var state: TurnSystemNetwork.State { get set }
    var currentPlayer: GenericPlayer? { get }

    func getNextPlayer() -> GenericPlayer?
    func getFirstPlayer() -> GenericPlayer?
    func processNetworkTurnActions(forTurnNumber turnNum: Int,
                                   playerActionPairs: [(String, [PlayerAction])])
    func waitForTurnFinish()
    func endTurn()
}
