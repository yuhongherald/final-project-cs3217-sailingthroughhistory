//
//  PlayerActionAdapterFactory.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class PlayerActionAdapterFactory: GenericPlayerActionAdapterFactory {
    func create(stateVariable: GameVariable<TurnSystemNetwork.State>,
                networkInfo: NetworkInfo,
                data: GenericTurnSystemState) -> GenericPlayerActionAdapter {
        return PlayerActionAdapter(stateVariable: stateVariable,
                                   networkInfo: networkInfo,
                                   data: data)
    }
}
