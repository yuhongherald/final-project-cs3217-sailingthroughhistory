//
//  PlayerTableViewCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

enum GameParameterItemType {
    case player
    case turn
}

enum FieldType: Int {
    case name
    case number
}

protocol GameParameterItem {
    var type: GameParameterItemType { get }
    var sectionTitle: String { get }
}

class PlayerParameterItem: GameParameterItem {
    var type: GameParameterItemType {
        return .player
    }

    var sectionTitle: String {
        return "Player Parameter"
    }

    var playerParameter: PlayerParameter

    init(playerParameter: PlayerParameter) {
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

class PlayerTableViewCell: UITableViewCell {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var moneyField: UITextField!

    var item: GameParameterItem? {
        didSet {
            guard let item = item as? PlayerParameterItem else {
                return
            }

            nameField.text = item.playerParameter.getName()
            moneyField.text = String(item.playerParameter.getMoney())

            nameField.tag = FieldType.name.rawValue
            moneyField.tag = FieldType.number.rawValue
        }
    }
}

class TurnTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!

    var item: GameParameterItem? {
        didSet {
            guard let item = item as? TurnParameterItem else {
                return
            }

            label.text = item.label
            guard let input = item.input else {
                textField.text = ""
                return
            }
            textField.text = String(input)
            textField.tag = FieldType.number.rawValue
        }
    }
}
