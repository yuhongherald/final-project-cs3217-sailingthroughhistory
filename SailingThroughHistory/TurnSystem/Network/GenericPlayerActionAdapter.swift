//
//  GenericPlayerActionAdapter.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

//protocol GenericPlayerActionAdapter {
//
//  PlayerActionAdapter.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericPlayerActionAdapter {
    func process(action: PlayerAction, for player: GenericPlayer) throws -> GameMessage?
    func handle(tradeAction: PlayerAction, by player: GenericPlayer) throws -> GameMessage?
    func register(portTaxAction action: PlayerAction,
                  by player: GenericPlayer) throws -> GameMessage?
    func handleSetTax()
    func playerMove(_ player: GenericPlayer, _ nodeId: Int, isEnd: Bool) -> GameMessage?
}
