//
//  UIEventTableCell.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 15/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class UIEventTableCell: UITableViewCell {
    @IBOutlet private weak var labelView: UILabel! {
        didSet {
            labelView.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet private weak var buttonView: UIButtonRounded!
    var buttonPressedCallback: (() -> Void)?

    func set(label: String) {
        labelView.text = label
    }

    func set(buttonLabel: String) {
        buttonView.setTitle(buttonLabel, for: .normal)
    }

    @IBAction private func buttonPressed(_ sender: UIButtonRounded) {
        buttonPressedCallback?()
    }
}
