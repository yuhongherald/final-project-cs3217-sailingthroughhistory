//
//  PlayerTableViewCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

enum FieldType: Int {
    case name
    case money
}

class PlayerTableViewCell: UITableViewCell {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var moneyField: UITextField!
}
