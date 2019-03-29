//
//  RoomViewCell.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class RoomViewCell: UITableViewCell {
    @IBOutlet private weak var joinButtonPressed: UIButton!
    @IBOutlet private weak var roomNameLabel: UILabel!

    @IBAction private func joinButtonPressed(_ sender: UIButton) {

    }

    func set(roomName: String) {
        roomNameLabel.text = roomName
    }
}
