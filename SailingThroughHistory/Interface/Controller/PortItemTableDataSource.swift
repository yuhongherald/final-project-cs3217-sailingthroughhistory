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
    private static let defaultPrice: Int = 100
    private static let buyButtonLabel = "Buy"
    private static let sellButtonLabel = "Sell"
    private static let boughtSection = 0
    private static let soldSection = 1
    private let mainController: MainGameViewController
    private var playerCanInteract = false
    private var selectedPort: Port?
    private var itemsSold = [ItemParameter]()
    private var itemsBought = [ItemParameter]()

    init(mainController: MainGameViewController) {
        self.mainController = mainController
    }

    func didSelect(port: Port, playerCanInteract: Bool) {
        self.itemsSold = port.itemParametersSold
        self.playerCanInteract = playerCanInteract
        self.selectedPort = port
        // TODO: Update when bought array is added.
        //self.itemsBought = port.itemParametersBought
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PortItemTableDataSource.reuseIdentifier, for: indexPath)
            as? UIPortItemTableCell

        guard let tableCell = cell else {
            preconditionFailure("Cell does not inherit from UIPortItemTableCell.")
        }

        guard let port = selectedPort else {
            return tableCell
        }

        var array: [ItemParameter]
        switch indexPath.section {
        case PortItemTableDataSource.boughtSection:
            array = itemsBought
            let item = array[indexPath.row]
            tableCell.set(price: item.getSellValue(at: port) ??
                PortItemTableDataSource.defaultPrice)
            tableCell.set(buttonLabel: PortItemTableDataSource.sellButtonLabel)
            tableCell.buttonPressedCallback = { [weak self] in
                self?.mainController.portItemButtonPressed(action: .playerSell(item: item))
            }
        case PortItemTableDataSource.soldSection:
            array = itemsSold
            let item = array[indexPath.row]
            tableCell.set(price: array[indexPath.row].getBuyValue(at: port) ??
                PortItemTableDataSource.defaultPrice)
            tableCell.set(buttonLabel: PortItemTableDataSource.buyButtonLabel)
            tableCell.buttonPressedCallback = { [weak self] in
                self?.mainController.portItemButtonPressed(action: .playerBuy(item: item))
            }
        default:
            array = []
        }

        tableCell.set(name: array[indexPath.row].displayName)
        if !playerCanInteract {
            tableCell.disable()
        }

        return tableCell
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

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
