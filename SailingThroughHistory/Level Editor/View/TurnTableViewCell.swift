//
//  TurnTableViewCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/20/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

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
