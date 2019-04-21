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
    var data = [[GameParameterItem]]()
    var numOfTurnMsg = "Number of Turn: "

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
                if let moneyText = castedCell.moneyField.text {
                    item.playerParameter.set(money: Int(moneyText))
                }
            case .turn:
                guard let castedCell = cell as? TurnTableViewCell,
                    let item = castedCell.item as? TurnParameterItem else {
                    continue
                }

                guard let inputText = castedCell.textField.text else {
                    continue
                }

                guard let input = Int(inputText) else {
                    continue
                }

                item.game.numOfTurn = input
            }

        }
        self.dismiss(animated: true, completion: nil)
    }

    /// Associate controller with game parameter that it is supposed to edit.
    func initWith(game: GameParameter) {
        self.data.append(game.playerParameters.map {
            PlayerParameterItem(playerParameter: $0)
        })
        self.data.append([TurnParameterItem(label: numOfTurnMsg, game: game, input: game.numOfTurn)])
    }
}
