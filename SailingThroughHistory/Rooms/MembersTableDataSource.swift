//
//  PlayersTableDataSource.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 1/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class MembersTableDataSource: NSObject, UITableViewDataSource {
    private static let reuseIdentifier = "waitingRoomCell"
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MembersTableDataSource.reuseIdentifier,
                                                       for: indexPath)
            as? WaitingRoomViewCell else {
                fatalError("Cells are not instances of RoomViewCell")
        }
        let player = waitingRoom.players[indexPath.row]
        cell.changeButtonPressedCallback = { [weak self] in
            self?.waitingRoom.changeTeam(of: player.playerName)
        }
        cell.set(playerName: player.playerName)
        cell.set(teamName: player.teamName ?? "No team")
        return cell
    }
}
