//
//  PlayersTableDataSource.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 1/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class MembersTableDataSource: NSObject, UITableViewDataSource, UITextFieldDelegate {
    private let deviceId: String
    private let mainController: WaitingRoomViewController
    private static let reuseIdentifier = "waitingRoomCell"
    private let view: UITableView
    private var waitingRoom: GameRoom

    init(withView view: UITableView, withRoom waitingRoom: GameRoom, mainController: WaitingRoomViewController) {
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
            self?.waitingRoom.changeTeam(of: player.identifier)
        }
        cell.removeButtonPressedCallback = { [weak self] in
            self?.waitingRoom.remove(player: player.identifier)
        }
        cell.delegate = self
        cell.set(playerName: player.playerName)
        cell.renameButtonPressedCallback = { [weak self] name in
            self?.waitingRoom.changeName(of: player.identifier, to: name)
        }
        let isMaster = waitingRoom.isRoomMaster()
        if isMaster {
            cell.makeGameMasterButtonPressedCallback = { [weak self] in
                self?.waitingRoom.makeGameMaster(player.identifier)
            }
        }
        cell.enableButton( isMaster || player.deviceId == self.deviceId)
        cell.disableTextField()
        if player.isGameMaster {
            cell.set(teamName: "Game Master")
        } else {
            cell.set(teamName: player.teamName ?? "No team")
        }
        return cell
    }
}
