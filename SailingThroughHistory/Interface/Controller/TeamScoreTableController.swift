//
//  TeamScoreTableController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 11/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

/// Controller for showing team scores. i.e Total team money.
class TeamScoreTableController: NSObject {
    private static let header = "Total Team Money:"
    weak var tableView: UITableView?
    var scores: [(Team, Int)]

    init(tableView: UITableView, scores: [Team: Int]) {
        self.tableView = tableView
        self.scores = Array(scores)
        super.init()
        tableView.dataSource = self
        tableView.reloadData()
    }

    /// Updates the team scores displayed to the ones in the input
    ///
    /// - Parameter scores: A dictionary of team as keys and their score as the associated value.
    func set(scores: [Team: Int]) {
        self.scores = Array(scores)
        tableView?.reloadData()
    }
}

extension TeamScoreTableController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let score = scores[indexPath.row]
        cell.textLabel?.text = "\(score.0.name): \(String(score.1))"
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TeamScoreTableController.header
    }
}
