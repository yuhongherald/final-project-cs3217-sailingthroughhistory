//
//  GenericPlayerActionAdapterFactory.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericPlayerActionAdapterFactory {
    func create(stateVariable: GameVariable<TurnSystemNetwork.State>,
                networkInfo: NetworkInfo,
                data: GenericTurnSystemState) -> GenericPlayerActionAdapter
}
