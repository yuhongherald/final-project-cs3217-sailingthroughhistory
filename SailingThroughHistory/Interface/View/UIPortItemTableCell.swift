//
//  UIPortItemTableCell.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class UIPortItemTableCell: UITableViewCell {

    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var itemPriceLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButtonRounded!

    var buttonPressedCallback: (() -> Void)?

    @IBAction func buttonPressed(_ sender: UIButton) {
        buttonPressedCallback?()
    }

    func set(name: String) {
        itemNameLabel.text = name
    }

    func set(price: Int) {
        itemPriceLabel.text = String(price)
    }

    func set(buttonLabel: String) {
        actionButton.setTitle(buttonLabel, for: .normal)
    }

    func disable() {
        actionButton.isEnabled = false
        actionButton.set(color: UIColor.lightGray)
    }
}
