//
//  PlayersTableDataSource.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 1/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class MembersTableDataSource: NSObject, UITableViewDataSource {
    private let view: UITableView
    private var waitingRoom: WaitingRoom

    init(withView view: UITableView, withRoom waitingRoom: WaitingRoom) {
        self.view = view
        self.waitingRoom = waitingRoom
        super.init()
        self.waitingRoom.subscribeToMembers(with: { _ in
            view.reloadData()
        }, observer: self)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waitingRoom.players.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value2, reuseIdentifier: nil)
        let player = waitingRoom.players[indexPath.row]

        cell.textLabel?.text = player.playerName
        cell.detailTextLabel?.text = player.teamName ?? "No team"
        return cell
    }
}
