//
//  MainGameViewController+TableViewDelegate.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

/// Controller responsible for showing items that are sold/bought at a port.
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
    private var itemParametersSoldByPort = [ItemParameter]()
    private var itemParametersBoughtByPort = [ItemParameter]()

    /// Default constructor with delegate for when user attempts to trade at the port.
    ///
    /// - Parameter delegate: Delegate for this controller.
    init(delegate: PortItemTableControllerDelegate) {
        self.delegate = delegate
    }

    /// Called when user selects a port. Shows the items traded at this port along with their information.
    ///
    /// - Parameters:
    ///   - port: The port selected
    ///   - playerCanInteract: Whether the user can trade at the port.
    func didSelect(port: Port, playerCanInteract: Bool) {
        self.itemParametersSoldByPort = port.itemParametersSoldByPort
        self.itemParametersBoughtByPort = port.itemParametersBoughtByPort
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

        var array: [ItemParameter]
        switch indexPath.section {
        case PortItemTableController.boughtSection:
            array = itemParametersBoughtByPort
            let itemParameter = array[indexPath.row]
            tableCell.set(price: port.getSellValue(of: itemParameter) ??
                PortItemTableController.defaultPrice)
            tableCell.set(buttonLabel: PortItemTableController.sellButtonLabel)
            tableCell.buttonPressedCallback = { [weak self] in
                self?.delegate?.portItemButtonPressed(action: .playerSell(itemParameter: itemParameter))
            }
        case PortItemTableController.soldSection:
            array = itemParametersSoldByPort
            let itemParameter = array[indexPath.row]
            tableCell.set(price: port.getBuyValue(of: array[indexPath.row]) ??
                PortItemTableController.defaultPrice)
            tableCell.set(buttonLabel: PortItemTableController.buyButtonLabel)
            tableCell.buttonPressedCallback = { [weak self] in
                self?.delegate?.portItemButtonPressed(action: .playerBuy(itemParameter: itemParameter))
            }
        default:
            array = []
        }
        let itemParameter = array[indexPath.row]
        tableCell.set(name: "\(itemParameter.rawValue) \(itemParameter.unitWeight)\(InterfaceConstants.weightSuffix)")
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
            return itemParametersBoughtByPort.count
        case PortItemTableController.soldSection:
            return itemParametersSoldByPort.count
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
