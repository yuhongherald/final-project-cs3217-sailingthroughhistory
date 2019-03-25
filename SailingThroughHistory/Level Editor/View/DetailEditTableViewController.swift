//
//  DetailEditTable.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class DetailEditTableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var data: [[GameParameterItem]] = {
        var arr = [[GameParameterItem]]()
        arr.append([TurnParameterItem(label: "Number of Turn: ", input: nil),
                    TurnParameterItem(label: "Time Limit Per Turn (sec): ", input: nil)])
        return arr
    }()

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        self.navigationController?.isToolbarHidden = false
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmPressed(_ sender: Any) {
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPath(for: cell) else {
                continue
            }

            switch data[indexPath.section][indexPath.item].type {
            case .player:
                guard let castedCell = cell as? PlayerTableViewCell,
                    let item = castedCell.item as? PlayerParameterItem else {
                    continue
                }
                if let name = castedCell.nameField.text,
                    let moneyText = castedCell.moneyField.text {
                    item.playerParameter.set(name: name, money: Int(moneyText))
                }
            case .turn:
                guard let castedCell = cell as? TurnTableViewCell,
                let item = castedCell.item as? TurnParameterItem else {
                    continue
                }

                // store
            default:
                continue
            }

        }
        self.dismiss(animated: true, completion: nil)
    }

    func initWith(game: GameParameter) {
        self.data.append(game.getPlayerParameters().map {
            PlayerParameterItem(playerParameter: $0)
        })
    }
}
