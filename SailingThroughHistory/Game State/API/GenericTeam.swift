//
//  GenericTeam.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/28/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Defines the behaviors that a player Team needs to support.
/// Players are part of a Team in the game
import Foundation

protocol GenericTeam: Codable {
    var name: String { get }
    var money: GameVariable<Int> { get }

    init(name: String)
    func updateMoney(by amount: Int)
}

func == (lhs: GenericTeam, rhs: GenericTeam?) -> Bool {
    return lhs.name == rhs?.name
}

func != (lhs: GenericTeam, rhs: GenericTeam?) -> Bool {
    return !(lhs == rhs)
}
