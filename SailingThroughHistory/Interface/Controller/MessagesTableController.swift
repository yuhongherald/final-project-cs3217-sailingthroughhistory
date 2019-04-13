//
//  MessagesTableController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class MessagesTableController: NSObject {
    private weak var tableView: UITableView?
    private var messages = [GameMessage]()

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        reloadMessages()
    }

    func set(messages: [GameMessage]) {
        self.messages = messages
        reloadMessages()
    }

    private func reloadMessages() {
        tableView?.reloadData()
        guard let numRows = tableView?.numberOfRows(inSection: 0) else {
            return
        }

        if numRows > 0 {
            tableView?.scrollToRow(at: IndexPath(row: numRows - 1, section: 0), at: .bottom, animated: true)
        }
    }

    private func convertToString(from gameMessage: GameMessage) -> String {
        switch gameMessage {
        case .playerAction(let name, let message):
            return "\(name) \(message)"
        case .event(let name, let message):
            return "\(name) \(message)"
        }
    }
}

extension MessagesTableController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let message = messages[indexPath.row]
        cell.textLabel?.text = convertToString(from: message)

        return cell
    }
}
