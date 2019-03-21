//
//  Board.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericGameLogic {
    // TODO
    // update sea, mark as dirty if weather changes

    // update ports, stub to change prices
    // update npcs, check they moved into a port, update port owner's money
    // update players, check they moved into a port
    // update pirates, check they moved into a player

    var gameState: GenericGameState? { get set }
    func getUpdatables(deltaTime: Double) -> AnyIterator<Updatable>

}
