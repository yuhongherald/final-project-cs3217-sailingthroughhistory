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

class TeamParameterItem: GameParameterItem {
    var type: GameParameterItemType {
        return .player
    }

    var sectionTitle: String {
        return "Team Parameter"
    }

    var playerParameter: PlayerParameter

    init(playerParameter: PlayerParameter) {
        self.playerParameter = playerParameter
    }
}

class TeamTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moneyField: UITextField!

    var item: GameParameterItem? {
        didSet {
            guard let item = item as? TeamParameterItem else {
                return
            }

            nameLabel.text = item.playerParameter.getName()
            moneyField.text = String(item.playerParameter.getMoney())

            nameLabel.tag = FieldType.name.rawValue
            moneyField.tag = FieldType.number.rawValue
        }
    }
}
