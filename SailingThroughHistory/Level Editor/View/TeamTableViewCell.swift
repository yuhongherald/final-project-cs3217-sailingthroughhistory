//
//  PlayerTableViewCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

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
