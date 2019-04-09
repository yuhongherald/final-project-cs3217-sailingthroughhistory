//
//  AvailableUpgradesDataSource.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class AvailableUpgradesDataSource: NSObject, UITableViewDataSource {
    private static let reuseIdentifier: String = "upgradesTableCell"
    private static let header = "Available Upgrades"
    private static let buttonLabel = "Buy"
    private let upgrades: [Upgrade]
    private weak var mainController: MainGameViewController?

    var enabled = false

    init(mainController: MainGameViewController, availableUpgrades: [Upgrade]) {
        self.mainController = mainController
        self.upgrades = availableUpgrades
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AvailableUpgradesDataSource.reuseIdentifier, for: indexPath)
            as? UITradeTableCell

        guard let tableCell = cell else {
            preconditionFailure("Cell does not inherit from UITradeTableCell.")
        }

        let upgrade = upgrades[indexPath.row]
        tableCell.set(name: upgrade.name)
        tableCell.set(price: upgrade.cost)
        tableCell.set(buttonLabel: AvailableUpgradesDataSource.buttonLabel)
        tableCell.buttonPressedCallback = { [weak self] in
            self?.mainController?.buy(upgrade: upgrade)
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
        return AvailableUpgradesDataSource.header
    }
}
