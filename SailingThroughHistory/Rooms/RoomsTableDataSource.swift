//
//  RoomsTableDataSource.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class RoomsTableDataSource: NSObject, UITableViewDataSource {
    private static let reuseIdentifier = "roomCell"
    private let view: UITableView
    private var rooms: Rooms
    private let mainController: RoomsMenuViewController

    init(withView view: UITableView, mainController: RoomsMenuViewController) {
        self.view = view
        self.rooms = Rooms()
        self.mainController = mainController
        super.init()
        self.rooms.subscribe { _ in
            view.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.rooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoomsTableDataSource.reuseIdentifier,
                                                       for: indexPath)
            as? RoomViewCell else {
                fatalError("Cells are not instances of RoomViewCell")
        }
        let room = rooms.rooms[indexPath.row]
        cell.joinButtonPressedCallback = { [weak self] in
            self?.mainController.join(room: room)
        }
        cell.set(roomName: room.name)
        return cell
    }
}
