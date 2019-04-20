//
//  File.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/26/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//
import UIKit

extension DetailEditTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = data[indexPath.section][indexPath.item]
        switch item.type {
        case .player:
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "playerIdentifier") as? TeamTableViewCell else {
                fatalError("The dequeued cell is not an instance of PlayerTableViewCell.")
            }
            cell.item = item

            return cell
        case .turn:
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "turnIdentifier") as? TurnTableViewCell else {
                fatalError("The dequeued cell is not an instance of TurnTableViewCell.")
            }
            cell.item = item

            return cell
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section][0].sectionTitle
    }
}

extension DetailEditTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        switch textField.tag {
        case FieldType.number.rawValue:
            let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
            return string.rangeOfCharacter(from: invalidCharacters) == nil
        default:
            return true
        }
    }
}
