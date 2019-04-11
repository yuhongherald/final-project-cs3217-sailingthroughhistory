//
//  PlayersTableDataSource.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 1/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class MembersTableDataSource: NSObject, UITableViewDataSource {
    private let deviceId: String
    private let mainController: WaitingRoomViewController
    private static let reuseIdentifier = "waitingRoomCell"
    private let view: UITableView
    private var waitingRoom: WaitingRoom

    init(withView view: UITableView, withRoom waitingRoom: WaitingRoom, mainController: WaitingRoomViewController) {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            fatalError("Device has no uuid")
        }
        self.deviceId = deviceId
        self.view = view
        self.waitingRoom = waitingRoom
        self.mainController = mainController
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
        cell.removeButtonPressedCallback = { [weak self] in
            self?.waitingRoom.remove(player: player.playerName, with: { error in
                let alert = ControllerUtils.getGenericAlert(titled: error, withMsg: "")
                self?.mainController.present(alert, animated: true, completion: nil)
            })
        }
        cell.enableButton(player.deviceId == self.deviceId)
        cell.set(playerName: player.playerName)
        cell.set(teamName: player.teamName ?? "No team")
        return cell
    }
}
