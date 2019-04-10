//
//  WaitingRoomCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/10/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class WaitingRoomViewCell: UITableViewCell {
    @IBOutlet private weak var changeButtonPressed: UIButton!
    @IBOutlet private weak var playerNameLabel: UILabel!
    @IBOutlet private weak var teamNameLabel: UILabel!
    var changeButtonPressedCallback: (() -> Void)?

    @IBAction private func changeButtonPressed(_ sender: UIButton) {
        changeButtonPressedCallback?()
    }

    func set(playerName: String) {
        playerNameLabel.text = playerName
    }

    func set(teamName: String) {
        teamNameLabel.text = teamName
    }
}
