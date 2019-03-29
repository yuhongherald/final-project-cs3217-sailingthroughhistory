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

    init(withView view: UITableView) {
        self.view = view
        self.rooms = Rooms()
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

        cell.set(roomName: rooms.rooms[indexPath.row].name)
        return cell
    }
}
