//
//  DetailEditTable.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class DetailEditTableViewController: UITableViewController {
    var players = ["player1", "player2"]
    var playerParameters = [PlayerParameter]()

    override func viewDidLoad() {
        self.navigationController?.isToolbarHidden = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerIdentifier", for: indexPath)
        guard let playerCell = cell as? PlayerTableViewCell else {
            fatalError("The dequeued cell is not an instance of PlayerTableViewCell.")
        }
        playerCell.label.text = players[indexPath.item]

        return playerCell
    }

    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
