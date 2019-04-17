//
//  MainGameViewController+TableViewDelegate.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class PortItemTableController: NSObject, UITableViewDataSource, UITableViewDelegate {
    private static let reuseIdentifier: String = "itemsTableCell"
    private static let defaultPrice: Int = 100
    private static let buyButtonLabel = "Buy"
    private static let sellButtonLabel = "Sell"
    private static let boughtSection = 0
    private static let soldSection = 1
    private static let numSections = 2
    private weak var delegate: PortItemTableControllerDelegate?
    private var playerCanInteract = false
    private var selectedPort: Port?
    private var itemTypesSoldByPort = [ItemType]()
    private var itemTypesBoughtByPort = [ItemType]()

    init(delegate: PortItemTableControllerDelegate) {
        self.delegate = delegate
    }

    func didSelect(port: Port, playerCanInteract: Bool) {
        self.itemTypesSoldByPort = port.itemParametersSoldByPort
        self.itemTypesBoughtByPort = port.itemParametersBoughtByPort
        self.playerCanInteract = playerCanInteract
        self.selectedPort = port
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PortItemTableController.reuseIdentifier, for: indexPath)
            as? UITradeTableCell

        guard let tableCell = cell else {
            preconditionFailure("Cell does not inherit from UITradeTableCell.")
        }

        guard let port = selectedPort else {
            return tableCell
        }

        var array: [ItemType]
        switch indexPath.section {
        case PortItemTableController.boughtSection:
            array = itemTypesBoughtByPort
            let item = array[indexPath.row]
            tableCell.set(price: port.getSellValue(of: item) ??
                PortItemTableController.defaultPrice)
            tableCell.set(buttonLabel: PortItemTableController.sellButtonLabel)
            tableCell.buttonPressedCallback = { [weak self] in
                self?.delegate?.portItemButtonPressed(action: .playerSell(item: item))
            }
        case PortItemTableController.soldSection:
            array = itemTypesSoldByPort
            let item = array[indexPath.row]
            tableCell.set(price: port.getBuyValue(of: array[indexPath.row]) ??
                PortItemTableController.defaultPrice)
            tableCell.set(buttonLabel: PortItemTableController.buyButtonLabel)
            tableCell.buttonPressedCallback = { [weak self] in
                self?.delegate?.portItemButtonPressed(action: .playerBuy(item: item))
            }
        default:
            array = []
        }

        tableCell.set(name: array[indexPath.row].rawValue)
        if playerCanInteract {
            tableCell.enable()
        } else {
            tableCell.disable()
        }

        return tableCell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return PortItemTableController.numSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case PortItemTableController.boughtSection:
            return itemTypesBoughtByPort.count
        case PortItemTableController.soldSection:
            return itemTypesSoldByPort.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case PortItemTableController.boughtSection:
            return "Buying"
        case PortItemTableController.soldSection:
            return "Selling"
        default:
            return nil
        }
    }
}
