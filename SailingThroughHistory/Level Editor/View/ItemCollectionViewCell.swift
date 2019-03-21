//
//  ItemCollectionViewCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/21/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

enum TextFieldTag: Int {
    case sellField = 1
    case buyField = 2
}

class ItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var sellField: UITextField!
    @IBOutlet weak var buyField: UITextField!

    var item: ItemParameter?
    var port: Port?
}
