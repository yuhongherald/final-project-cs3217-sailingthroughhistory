//
//  MainGameViewController+TableViewDelegate.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class PortItemTableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    private static let reuseIdentifier: String = "itemsTableCell"
    private static let boughtSection = 0
    private static let soldSection = 1
    var itemsSold = [ItemParameter]()
    var itemsBought = [ItemParameter]()

    func didSelect(port: Port) {
        self.itemsSold = port.itemParametersSold
        self.itemsBought = port.itemParametersBought
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default,
                               reuseIdentifier: PortItemTableDataSource.reuseIdentifier)
        var array: [ItemParameter]?
        switch indexPath.section {
        case PortItemTableDataSource.boughtSection:
            array = itemsBought
        case PortItemTableDataSource.soldSection:
            array = itemsSold
        default:
            break
        }

        cell.textLabel?.text = array?[indexPath.row].displayName

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case PortItemTableDataSource.boughtSection:
            return itemsBought.count
        case PortItemTableDataSource.soldSection:
            return itemsSold.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case PortItemTableDataSource.boughtSection:
            return "Buying"
        case PortItemTableDataSource.soldSection:
            return "Selling"
        default:
            return nil
        }
    }
}
