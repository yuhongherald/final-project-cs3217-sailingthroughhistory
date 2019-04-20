//
//  GameParameter.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/21/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

/**
 * Protocol for values of GameParameter.
 */
protocol GameParameterItem {
    var type: GameParameterItemType { get }
    var sectionTitle: String { get }
}

enum GameParameterItemType {
    case player
    case turn
}

enum FieldType: Int {
    case name
    case number
}

class TeamParameterItem: GameParameterItem {
    var type: GameParameterItemType {
        return .player
    }

    var sectionTitle: String {
        return "Team Parameter"
    }

    var playerParameter: TeamParameter

    init(playerParameter: TeamParameter) {
        self.playerParameter = playerParameter
    }
}

class TurnParameterItem: GameParameterItem {
    var type: GameParameterItemType {
        return .turn
    }

    var sectionTitle: String {
        return "Game Turn"
    }

    var label: String
    var input: Int?
    var game: GameParameter

    init(label: String, game: GameParameter, input: Int) {
        self.label = label
        self.input = input
        self.game = game
    }
}
