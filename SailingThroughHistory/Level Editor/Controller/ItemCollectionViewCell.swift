//
//  ItemCollectionViewCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/21/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var consumableToggle: UISwitch!
    @IBOutlet weak var lifeField: UITextField!
    @IBOutlet weak var sellField: UITextField!
    @IBOutlet weak var buyField: UITextField!
    @IBAction func switchClicked(_ sender: Any) {
        if consumableToggle.isOn {
            lifeField.isEnabled = true
        } else {
            lifeField.isEnabled = false
        }
    }
}
