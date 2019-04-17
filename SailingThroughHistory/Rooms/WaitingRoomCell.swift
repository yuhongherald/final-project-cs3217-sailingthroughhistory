//
//  WaitingRoomCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/10/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class WaitingRoomViewCell: UITableViewCell {
    @IBOutlet private weak var renameButton: UIButton!
    @IBOutlet private weak var changeButton: UIButton!
    @IBOutlet private weak var makeGameMasterButton: UIButton!
    @IBOutlet private weak var removeButton: UIButton!
    @IBOutlet private weak var playerNameTextField: UITextField!
    @IBOutlet private weak var teamNameLabel: UILabel!
    var delegate: UITextFieldDelegate? {
        didSet {
            playerNameTextField.delegate = delegate
        }
    }
    var changeButtonPressedCallback: (() -> Void)?
    var removeButtonPressedCallback: (() -> Void)?
    var renameButtonPressedCallback: ((String) -> Void)?
    var makeGameMasterButtonPressedCallback: (() -> Void)? {
        didSet {
            makeGameMasterButton.isHidden = makeGameMasterButtonPressedCallback == nil
        }
    }

    @IBAction func renameButtonPressed(_ sender: UIButton) {
        if playerNameTextField.isEnabled {
            playerNameTextField.isEnabled = false
            playerNameTextField.borderStyle = .none
            renameButtonPressedCallback?(playerNameTextField.text ?? "")
        } else {
            playerNameTextField.isEnabled = true
            playerNameTextField.borderStyle = .line
        }
    }

    @IBAction private func changeButtonPressed(_ sender: UIButton) {
        changeButtonPressedCallback?()
    }

    @IBAction private func removeButtonPressed(_ sender: UIButton) {
        removeButtonPressedCallback?()
    }

    @IBAction private func makeGameMasterButtonPressed(_ sender: UIButton) {
        makeGameMasterButtonPressedCallback?()
    }

    func set(playerName: String) {
        playerNameTextField.text = playerName
    }

    func set(teamName: String) {
        teamNameLabel.text = teamName
    }

    func enableButton(_ bool: Bool) {
        changeButton.isEnabled = bool
        removeButton.isEnabled = bool
    }

    func disableTextField() {
        playerNameTextField.borderStyle = .none
        playerNameTextField.isEnabled = false
    }
}
