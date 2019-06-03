//
//  AvailableUpgradesDataSource.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

/// The controller responsible for showing the available upgrades.
class AvailableUpgradesController: NSObject, UITableViewDataSource {
    private static let reuseIdentifier: String = "upgradesTableCell"
    private static let header = "Available Upgrades"
    private static let buttonLabel = "Buy"
    private let upgrades: [Upgrade]
    private weak var delegate: AvailableUpgradesControllerDelegate?

    var enabled = false

    /// Default constructor for the input available upgrades.
    ///
    /// - Parameters:
    ///   - delegate: Delegate for this controller for when player attempts to buy an upgrade
    ///   - availableUpgrades: Available upgrades for the user.
    init(delegate: AvailableUpgradesControllerDelegate, availableUpgrades: [Upgrade]) {
        self.delegate = delegate
        self.upgrades = availableUpgrades
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AvailableUpgradesController.reuseIdentifier, for: indexPath)
            as? UITradeTableCell

        guard let tableCell = cell else {
            preconditionFailure("Cell does not inherit from UITradeTableCell.")
        }

        let upgrade = upgrades[indexPath.row]
        tableCell.set(name: upgrade.name)
        tableCell.set(price: upgrade.cost)
        tableCell.set(buttonLabel: AvailableUpgradesController.buttonLabel)
        tableCell.buttonPressedCallback = { [weak self] in
            self?.delegate?.buy(upgrade: upgrade)
        }

        return tableCell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upgrades.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return AvailableUpgradesController.header
    }
}
