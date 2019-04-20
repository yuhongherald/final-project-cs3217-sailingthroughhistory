//
//  PlayerItemsTableDataSource.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 23/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

/// Controller for table that shows items belonging to a player.
class PlayerItemsTableController: NSObject, UITableViewDataSource {
    private static let reuseIdentifier = "playerItemsTableCell"
    private static let header = "Items"
    private weak var tableView: UITableView?
    private let player: GenericPlayer
    private var items = [GenericItem]()

    /// Constructor for PlayerItemsTableController for a given player and view to show it on.
    ///
    /// - Parameters:
    ///   - player: The player whose items to show
    ///   - tableView: The view to show the items on
    init(player: GenericPlayer, tableView: UITableView) {
        self.player = player
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        self.subscribeToItems()
    }

    private func subscribeToItems() {
        player.subscribeToItems { [weak self] _, items in
            self?.items = items
            self?.tableView?.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1,
                                   reuseIdentifier: PlayerItemsTableController.reuseIdentifier)

        let item = items[indexPath.row]

        cell.textLabel?.text = "\(item.name) \(item.itemParameter.unitWeight)\(InterfaceConstants.weightSuffix)"
        cell.detailTextLabel?.text = "\(InterfaceConstants.itemQuantityPrefix)\(item.quantity)"

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return PlayerItemsTableController.header
    }
}
