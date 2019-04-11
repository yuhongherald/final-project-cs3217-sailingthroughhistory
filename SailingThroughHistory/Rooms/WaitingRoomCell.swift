//
//  WaitingRoomCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/10/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class WaitingRoomViewCell: UITableViewCell {
    @IBOutlet private weak var changeButton: UIButton!
    @IBOutlet private weak var removeButton: UIButton!
    @IBOutlet private weak var playerNameLabel: UILabel!
    @IBOutlet private weak var teamNameLabel: UILabel!
    var changeButtonPressedCallback: (() -> Void)?
    var removeButtonPressedCallback: (() -> Void)?

    @IBAction private func changeButtonPressed(_ sender: UIButton) {
        changeButtonPressedCallback?()
    }

    @IBAction private func removeButtonPressed(_ sender: UIButton) {
        removeButtonPressedCallback?()
    }

    func set(playerName: String) {
        playerNameLabel.text = playerName
    }

    func set(teamName: String) {
        teamNameLabel.text = teamName
    }

    func enableButton(_ bool: Bool) {
        changeButton.isEnabled = bool
        removeButton.isEnabled = bool
    }
}
