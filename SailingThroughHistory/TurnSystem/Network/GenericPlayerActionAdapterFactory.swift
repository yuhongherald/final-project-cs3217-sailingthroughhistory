//
//  GenericPlayerActionAdapterFactory.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * A factory used to create a GenericPlayerActionAdapater in the context of a
 * GenericTurnSystemNetwork.
 */
protocol GenericPlayerActionAdapterFactory {
    /// Creates a GenericPlayerActionAdapter given the context of a
    /// GenericTurnSystemNetwork.
    /// - Parameters:
    ///     - stateVariable: A reference to the TurnSystemNetwork's state.
    ///     - networkInfo: Information about the network connection.
    ///     - data: The data which the PlayerActions take effect on.
    /// - Returns:
    ///     - The actionAdapter for the given context.
    func create(stateVariable: GameVariable<TurnSystemNetwork.State>,
                networkInfo: NetworkInfo,
                data: GenericTurnSystemState) -> GenericPlayerActionAdapter
}
