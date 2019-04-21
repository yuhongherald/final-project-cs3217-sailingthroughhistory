//
//  GenericPlayerInputControllerFactory.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A factory that creates a GenericPlayerInputController using the context of a
 * GenericTurnSystem
 */
protocol GenericPlayerInputControllerFactory {
    /// Creates a GenericPlayerInputController given the context of a
    /// GenericTurnSystem.
    /// - Parameters:
    ///     - network: The network that the controller runs on.
    ///     - data: The data which the controller operates on.
    /// - Returns:
    ///     - The controller for the given context.
    func create(network: GenericTurnSystemNetwork, data: GenericTurnSystemState)
        -> GenericPlayerInputController
}
