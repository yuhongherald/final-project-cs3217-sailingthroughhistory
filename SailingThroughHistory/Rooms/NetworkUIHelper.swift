//
//  NetworkUtil.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import FirebaseUI

struct NetworkUIHelper {
    private var dataSources = [NSObject]()

    mutating func bindRooms(to tableview: UITableView, withReuseIdentifier reuseIdentifier: String) {
        let query = FirestoreConstants
            .firestore
            .collection(FirestoreConstants.roomCollectionName)
            .whereField(FirestoreConstants.roomStartedKey, isEqualTo: false)
        dataSources.append(tableview.bind(toFirestoreQuery: query) { tableView, indexPath, snapshot in
            // Dequeue cell
            FirestoreRoom.deleteIfNecessary(named: snapshot.documentID)
            guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                as? RoomViewCell else {
                    fatalError("Cells are not instances of RoomViewCell")
            }

            cell.set(roomName: snapshot.documentID)
            return cell
        })
    }
}
