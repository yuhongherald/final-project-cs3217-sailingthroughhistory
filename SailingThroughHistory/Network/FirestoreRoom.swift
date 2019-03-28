//
//  FirebaseRoom.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import FirebaseFirestore

class FirestoreRoom: Room {
    let name: String
    private let firestore: Firestore

    init(named name: String, firestore: Firestore) {
        self.name = name
        self.firestore = firestore
    }

    static func getAllRooms(completion callback: @escaping ([Room]) -> Void) {
        FirestoreConstants.roomCollection.getDocuments { (snapshot, error) in
            callback(processRooms(snapshot: snapshot, error: error))
        }
    }

    private static func processRooms(snapshot: QuerySnapshot?, error: Error?) -> [Room] {
        guard let roomDocuments = snapshot?.documents else {
            fatalError("Failed to read rooms")
        }

        return roomDocuments
            .map { FirestoreRoom(named: $0.documentID, firestore: Firestore.firestore()) }
    }

    func getConnection(removalCallback: @escaping () -> Void, completion callback: @escaping (RoomConnection?, Error?) -> ()) {
        FirebaseRoomConnection.getConnection(for: self, removed: removalCallback, completion: callback)
    }
}
