//
//  DetailEditTable.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class DetailEditTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    var playerParameters: [PlayerParameter] = []

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        self.navigationController?.isToolbarHidden = false
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerParameters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerIdentifier", for: indexPath)
        guard let playerCell = cell as? PlayerTableViewCell else {
            fatalError("The dequeued cell is not an instance of PlayerTableViewCell.")
        }
        playerCell.nameField.text = playerParameters[indexPath.item].getName()
        playerCell.moneyField.text = String(playerParameters[indexPath.item].getMoney())
        playerCell.nameField.tag = FieldType.name.rawValue
        playerCell.moneyField.tag = FieldType.money.rawValue

        return playerCell
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmPressed(_ sender: Any) {
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPath(for: cell),
                let castedCell = cell as? PlayerTableViewCell else {
                    continue
            }
            let playerParam = playerParameters[indexPath.item]

            if let name = castedCell.nameField.text,
                let moneyText = castedCell.moneyField.text {
                playerParam.set(name: name, money: Int(moneyText))
            }
        }
        self.dismiss(animated: true, completion: nil)
    }

    func initWith(game: GameParameter) {
        self.playerParameters = game.getPlayerParameters()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        switch textField.tag {
        case FieldType.money.rawValue:
            let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
            return string.rangeOfCharacter(from: invalidCharacters) == nil
        default:
            return true
        }
    }
}
