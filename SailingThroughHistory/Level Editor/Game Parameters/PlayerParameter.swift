//
//  PlayerParameter.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class PlayerParameter {
    private var name: String!
    private var money: GameVariable<Int>!
    private var node: Node!

    init(name: String, money: Int, node: Node) {
        self.name = name
        self.money = GameVariable(value: money)
        self.node = node
    }

    func getPlayer() -> Player {
        return Player(name: name, node: node)
    }
}
